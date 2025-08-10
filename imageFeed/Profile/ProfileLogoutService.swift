import Foundation
import WebKit

protocol ProfileLogoutServiceProtocol: AnyObject {
    func logout()
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    static let shared = ProfileLogoutService()
    private init() {}
    
    func logout() {
        cleanCookies()
        ProfileService.shared.deleteProfile()
        ProfileImageService.shared.deleteProfileImage()
        ImagesListService.shared.deleteImageList()
        OAuth2TokenStorage.shared.deleteOAuth2Token()
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            window.rootViewController = SplashViewController()
        }
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
