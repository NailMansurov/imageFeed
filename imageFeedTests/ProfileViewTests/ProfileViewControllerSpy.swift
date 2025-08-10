@testable import imageFeed
import XCTest

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var profile: Profile?
    var profileImageURL: URL?
    
    func updateProfileDetails(profile: Profile) {
        self.profile = profile
    }
    
    func showDefaultProfile() {
        
    }
    
    func updateAvatar(url: URL?) {
        profileImageURL = url
    }
    
    func didTapLogoutButton() {
        
    }
}
