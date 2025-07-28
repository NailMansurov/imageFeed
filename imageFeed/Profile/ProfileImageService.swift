import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            task?.cancel()
        }
        
        guard let request = makeProfileImageRequest(username) else {
            print("[fetchProfileImageURL]: Невозможно создать URL запроса.")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.small
                completion(.success(userResult.profileImage.small))
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": userResult.profileImage.small]
                    )
            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка запроса: \(error.localizedDescription).")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(_ username: String) -> URLRequest? {
        guard let baseURL = Constants.defaultBaseURL,
              let url = URL(string: "/users/\(username)", relativeTo: baseURL) else {
            return nil
        }
        
        guard let token = oauth2TokenStorage.token else {
            assertionFailure("[makeProfileImageRequest]: Токен не найден")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
