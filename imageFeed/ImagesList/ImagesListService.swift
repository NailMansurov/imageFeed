import Foundation

enum ImagesListServiceError: Error {
    case invalidRequest
}


final class ImagesListService {
    static let shared = ImagesListService()
    
    // MARK: - Private properties
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let photosPerPage = 10
    private let dateFormatter = ISO8601DateFormatter()
    
    // MARK: - Notification
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    // MARK: - Public methods
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makeImageListRequest(page: nextPage, perPage: photosPerPage) else {
            print("[fetchPhotosNextPage]: Невозможно создать URL.")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let photoResult):
                    let newPhotos = photoResult.map {
                        Photo(from: $0, dateFormatter: self.dateFormatter)
                    }
                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    
                case .failure(let error):
                    print("[fetchPhotosNextPage]: \(error.localizedDescription)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeImageListRequest(page: Int, perPage: Int) -> URLRequest? {
        guard let token = oauth2TokenStorage.token else {
            print("[makeImageListRequest]: Токен не найден.")
            return nil
        }
        
        guard let url = URL(string: "/photos?page=\(page)&per_page=\(perPage)", relativeTo: Constants.defaultBaseURL) else {
            print("[makeImageListRequest]: Невозможно создать URL.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = oauth2TokenStorage.token else {
            print("[chahgeLike]: Токен не найден.")
            return
        }
        
        let httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        
        guard let url = URL(string: "/photos/\(photoId)/like", relativeTo: Constants.defaultBaseURL) else {
            print("[chahgeLike]: Неверный URL запрос.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error {
                print("[chahgeLike]: \(error).")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(ImagesListServiceError.invalidRequest))
                return
            }
            DispatchQueue.main.async {
                guard let self else { return }
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    var photo = self.photos[index]
                    photo.isLiked = isLike
                    self.photos[index] = photo
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }
    
    func deleteImageList() {
        photos.removeAll()
        task = nil
        lastLoadedPage = nil
    }
}
