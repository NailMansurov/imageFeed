import Foundation

final class ImagesListService {
    
    // MARK: - Private properties
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    // MARK: - Public methods
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage?.number ?? 0) + 1
    }
}
