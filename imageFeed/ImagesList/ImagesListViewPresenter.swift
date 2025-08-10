import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    func viewDidLoad()
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void)
    func photo(at indexPath: IndexPath) -> Photo
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private(set) var photos: [Photo] = []
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    
    init(view: ImagesListViewControllerProtocol, imagesListService: ImagesListServiceProtocol) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    func viewDidLoad() {
        setNotificationObserver()
        loadStartPhotos()
    }
    
    private func setNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateTableViewAnimated()
        }
    }
    
    private func loadStartPhotos(){
        if photos.isEmpty {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos
        let uniqueNewPhotos = newCount.filter { newPhoto in
            !photos.contains(where: { $0.id == newPhoto.id })
        }
        
        guard !uniqueNewPhotos.isEmpty else { return }
        
        photos.append(contentsOf: uniqueNewPhotos)
        view?.insertRows(from: oldCount, to: photos.count)
    }
    
    private func loadInitialPhotos(){
        if photos.isEmpty {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath, completion: @escaping (Result<Void, any Error>) -> Void) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.photos = self?.imagesListService.photos ?? []
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
}
