import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    private init() {}
    
    private func makeURLRequest (url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let baseURL = Constants.defaultBaseURL,
              let url = URL(string: "/me", relativeTo: baseURL)
        else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: ""])))
            print("[fetchProfile]: Неверный defaultBaseURL")
            return
        }
        
        let request = makeURLRequest(url: url, token: token)
        
        URLSession.shared.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            
            switch result {
            case . success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: profileResult.firstName + " " + profileResult.lastName,
                    bio: profileResult.bio ?? "")
                self.profile = profile
                completion(.success(profile))
                print("Профиль получен: \(profile)")
            case .failure(let error):
                completion(.failure(error))
                print("[fetchProfile]: Ошибка получения данных профиля: \(error)")
            }
            
        }.resume()
    }
}
