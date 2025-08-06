@testable import imageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    func testViewComntrollerCallsViewDidLoad1() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "ImagesListViewController") as? ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController?.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController?.view
        
        //then
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
}
