import Foundation

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
                    let newPhotos = photoResult.map { photoResult in
                        return Photo(id: photoResult.id,
                                     size: CGSize(width: photoResult.width,
                                                  height: photoResult.height),
                                     createdAt: self.dateFormatter.date(from: photoResult.createdAt),
                                     welcomeDescription: photoResult.description,
                                     thumbImageURL: photoResult.urls.thumb,
                                     largeImageURL: photoResult.urls.full,
                                     isLiked: photoResult.likedByUser)
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
        guard let baseURL = Constants.defaultBaseURL,
              let url = URL(string: "/photos", relativeTo: baseURL) else {
            print("[makeImageListRequest]: Невозможно создать URL.")
            return nil
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.unsplash.com"
        urlComponents.path = "/photos"
        
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("[ImagesListService]: Неверный URL запрос.")
            return nil
        }
        
        guard let token = oauth2TokenStorage.token else {
            print("[makeProfileImageRequest]: Токен не найден")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
