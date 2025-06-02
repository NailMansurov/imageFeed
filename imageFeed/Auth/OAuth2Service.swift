import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Не получен базовый URL.")
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
            print("Ошибка: Невозможно создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String,
                         completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 0)))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = decoded.accessToken
                    OAuth2TokenStorage.shared.token = token
                    completion(.success(token))
                } catch {
                    print("Ошибка при декодирвоании \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpStatusCode(let code, let data):
                        print("Ошибка, ответ сервера: \(code)")
                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
                            print("Ответ сервера: \(errorString)")
                        } else {
                            print("Нет ответа сервера или не удалось декодировать его")
                        }
                    case .urlRequestError(let requestError):
                        print("Ошибка: ответ сервера: \(requestError)")
                    case .urlSessionError:
                        print("Ошибка URLSession")
                    }
                } else {
                    print("Ошибка: \(error)")
                }
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
