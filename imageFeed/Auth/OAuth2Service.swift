import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("[makeOAuthTokenRequest]: Не получен базовый URL.")
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
            print("[makeOAuthTokenRequest]: Невозможно создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else{
            print("[fetchOAuthToken]: Повторный запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[fetchOAthToken]: Невозможно создать URL")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let decoded):
                    let token = decoded.accessToken
                    OAuth2TokenStorage.shared.token = token
                    completion(.success(token))
                case .failure(let error):
                    self?.handleError(error)
                    completion(.failure(error))
                }
                self?.task = nil
                self?.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }

    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let code, let data):
                print("Ошибка, ответ сервера: \(code)")
                print("[fetchAuthToken]: Ошибка, ответ свервера \(code)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("[fetchAuthToken]: Ответ сервера: \(errorString)")
                } else {
                    print("[fetchAuthToken]: Нет ответа сервера или не удалось декодировать его")
                }
            case .urlRequestError(let requestError):
                print("[fetchAuthToken]: Ошибка: ответ сервера: \(requestError)")
            case .urlSessionError:
                print("[fetchAuthToken]: Ошибка URLSession")
            }
        } else {
            print("[fetchAuthToken]: Ошибка: \(error)")
        }
    }
    
}
