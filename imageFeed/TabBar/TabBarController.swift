import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        let presenter = ProfileViewPresenter(
            profileService: ProfileService.shared,
            profileImageService: ProfileImageService.shared,
            profileLogoutService: ProfileLogoutService.shared
        )
        let profileViewController = ProfileViewController(presenter: presenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        viewControllers = [imagesListViewController, profileViewController]
    }
}
