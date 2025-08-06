import Foundation

protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
    func deleteProfile()
}


final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private init() {}
    
    private func makeURLRequest (url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            task?.cancel()
        }
        
        let url = URL(string: "/me", relativeTo: Constants.defaultBaseURL)
            guard let url = url else {
                print("[fetchProfile]: Не удалось создать URL")
                completion(.failure(URLError(.badURL)))
                return
            }
        
        let request = makeURLRequest(url: url, token: token)
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: profileResult.firstName + " " + profileResult.lastName,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? "")
                self.profile = profile
                completion(.success(profile))
                print("Профиль получен: \(profile)")
            case .failure(let error):
                completion(.failure(error))
                print("[fetchProfile]: Ошибка получения данных профиля: \(error)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func deleteProfile() {
        task = nil
        profile = nil
    }
}
