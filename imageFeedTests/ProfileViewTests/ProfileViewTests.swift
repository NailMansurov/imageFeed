@testable import imageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewComntrollerCallsViewDidLoad() {
        //given
        let presenter = ProfileViewPresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testSetProfileDetails() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profile = Profile(username: "username",
                              name: "name",
                              loginName: "@loginName",
                              bio: "bio"
        )
        
        //when
        viewController.updateProfileDetails(profile: profile)
        
        //then
        XCTAssertEqual(viewController.profile?.username, profile.username)
        XCTAssertEqual(viewController.profile?.name, profile.name)
        XCTAssertEqual(viewController.profile?.loginName, profile.loginName)
        XCTAssertEqual(viewController.profile?.bio, profile.bio)
    }
    
    func testSetProfileImageURL() {
        //given
        let viewControlle = ProfileViewControllerSpy()
        let url = URL(string: "https://example.com/profile.jpg")
        
        //when
        viewControlle.updateAvatar(url: url)
        
        //then
        XCTAssertEqual(viewControlle.profileImageURL, url)
    }
}
