import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    // Added task and lastCode
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String,
                         completion: @escaping (Result<String, Error>) -> Void) {
        //        guard let request = makeOAuthTokenRequest(code: code) else {
        //            DispatchQueue.main.async {
        //                completion(.failure(NSError(domain: "InvalidRequest", code: 0)))
        //            }
        //            return
        //        }
        assert(Thread.isMainThread)
//        if task != nil {
//            if lastCode != code {
//                task?.cancel()
//            } else {
//                completion(.failure(AuthServiceError.invalidRequest))
//                return
//            }
//        } else {
//            if lastCode == code {
//                completion(.failure(AuthServiceError.invalidRequest))
//            }
//        }
        
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
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let decoded):
                completion(.success(decoded.accessToken))
            case .failure(let error):
                print("[fetchOAuthToken]: Ошибка: \(error)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        
        self.task = task
        task.resume()
        
        //        let task = URLSession.shared.data(for: request) { result in
        //            switch result {
        //            case .success(let data):
        //                do {
        //                    let decoder = JSONDecoder()
        //                    decoder.keyDecodingStrategy = .convertFromSnakeCase
        //                    let decoded = try decoder.decode(OAuthTokenResponseBody.self, from: data)
        //                    let token = decoded.accessToken
        //                    OAuth2TokenStorage.shared.token = token
        //                    DispatchQueue.main.async {
        //                        completion(.success(token))
        //                    }
        //                } catch {
        //                    print("Ошибка при декодирвоании \(error)")
        //                    DispatchQueue.main.async {
        //                        completion(.failure(error))
        //                    }
        //                }
        //
        //            case .failure(let error):
        //                if let networkError = error as? NetworkError {
        //                    switch networkError {
        //                    case .httpStatusCode(let code, let data):
        //                        print("Ошибка, ответ сервера: \(code)")
        //                        if let data = data, let errorString = String(data: data, encoding: .utf8) {
        //                            print("Ответ сервера: \(errorString)")
        //                        } else {
        //                            print("Нет ответа сервера или не удалось декодировать его")
        //                        }
        //                    case .urlRequestError(let requestError):
        //                        print("Ошибка: ответ сервера: \(requestError)")
        //                    case .urlSessionError:
        //                        print("Ошибка URLSession")
        //                    }
        //                } else {
        //                    print("Ошибка: \(error)")
        //                }
        //                DispatchQueue.main.async {
        //                    completion(.failure(error))
        //                }
        //            }
        //        }
        //        task.resume()
        //    }
    }
}
