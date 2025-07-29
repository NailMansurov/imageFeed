import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    
    // MARK: - Private properties
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private var isLoading = false
    
    // MARK: - Notification
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    // MARK: - Public methods
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        self.lastLoadedPage = nextPage
        
        guard let request = makeImageListRequest(page: nextPage) else {
            assertionFailure("[fetchPhotosNextPage]: Невозможно создать URL")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResult):
                for response in photoResult {
                    let photo = Photo(
                        id: response.id,
                        size: CGSize(width: response.width, height: response.height),
                        createdAt: response.createdAt,
                        welcomeDescription: response.description,
                        thumbImageURL: response.imageURL.thumb,
                        largeImageURL: response.imageURL.full,
                        isLiked: response.isLiked
                    )
                    let existingIds = Set(self.photos.map { $0.id })
                    if !existingIds.contains(photo.id) {
                        self.photos.append(photo)}
                        //                    self.photos.append(photo)
                        
                    }
                    self.lastLoadedPage = nextPage
                    self.isLoading = false
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": self.photos]
                        )}
                case .failure(let error):
                    print("[fetchPhotosNextPage]: \(error.localizedDescription)")
                    self.isLoading = false
                }
                self.task = nil
            }
            self.task = task
            task.resume()
        }
        
        func makeImageListRequest(page: Int) -> URLRequest? {
            let photosPerPage = "10"
            
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.unsplash.com"
            components.path = "/photos"
            components.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: photosPerPage),
            ]
            
            guard let url = components.url else {
                assertionFailure("[makeImageListRequest]: Невозможно создать URL")
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.get.rawValue
            
            guard let token = oauth2TokenStorage.token else {
                assertionFailure("[makeImageListRequest]: Токен не найден")
                return nil
            }
            
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    }
