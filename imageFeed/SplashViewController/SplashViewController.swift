import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
            print("Token exists, fetching profile")
        } else {
            presentAuthViewController()
            print("Token is nil, showing authentication screen")
        }
        
    }
    
    private enum constraintsConstants {
        static let splashLogoWidth: CGFloat = 60
        static let splashLogoHeight: CGFloat = 60
    }
    
    private lazy var splashLogoImageView: UIImageView = {
        let imageView = UIImageView(image: R.image.splash_screen_logo())
        view.addSubview(imageView)
        return imageView
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashLogoImageView.widthAnchor.constraint(equalToConstant: constraintsConstants.splashLogoWidth),
            splashLogoImageView.heightAnchor.constraint(equalToConstant: constraintsConstants.splashLogoHeight),
            
            splashLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            splashLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setupUI() {
        view.addSubviews(
            splashLogoImageView
        )
        
    }

    func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            return
        }
        
        authVC.delegate = self
        
        let navigationController = UINavigationController(rootViewController: authVC)
        
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true, completion: nil)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgresssHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgresssHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                let username = profile.username
                
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                self.switchToTabBarController()
            case .failure:
                print("[fetchProfile]: Ошибка профиля")
                self.presentAuthViewController()
                break
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        UIBlockingProgresssHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            
            defer { UIBlockingProgresssHUD.dismiss() }
            
            switch result {
            case .success(let token):
                print("Токен получен: \(token)")
                self.oauth2TokenStorage.token = token
                self.fetchProfile(token)
            case .failure(let error):
                print("[authViewController]: Ошибка при получении токена: \(error.localizedDescription)")
                self.presentAuthViewController()
                break
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = oauth2TokenStorage.token else { return }
        
        fetchProfile(token)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        DispatchQueue.main.async {
            window.rootViewController = tabBarController
        }
    }
    
}
