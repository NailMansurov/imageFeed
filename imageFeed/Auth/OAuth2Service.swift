import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    func fetchOAuthToken(_ code: String,
                         completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            print("[fetchOAuthToken]: code совпадает с предыдущим lastCode == code")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            print("[fetchOAuthToken]: Не удалось создать URLRequest")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, any Error>) in
            switch result {
            case .success(let decoded):
                completion(.success(decoded.accessToken))
            case .failure(let error):
                print("[fetchOAuthToken]: Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("[makeOAuthTokenRequest]: Не получен базовый URL.")
            assertionFailure("Failed to create URL")
            
            return nil
        }
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("[makeOAuthTokenRequest]: Невозможно создать URL.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
