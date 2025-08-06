@testable import imageFeed
import XCTest

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var isViewDidLoadCalled = false
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func updateProfile() {
        
    }
    
    func setAvatar() {
        
    }
    
    func tapLogout() {
        
    }
    
    func setProfileNotificationObserver() {
        
    }
}
