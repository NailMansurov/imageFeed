@testable import imageFeed
import XCTest

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var photos: [imageFeed.Photo] = []
    var view: ImagesListViewControllerProtocol?
    var isViewDidLoadCalled = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        
    }
    
    func didTapLike(at indexPath: IndexPath, completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func photo(at indexPath: IndexPath) -> imageFeed.Photo {
        return photos[indexPath.row]
    }
}
