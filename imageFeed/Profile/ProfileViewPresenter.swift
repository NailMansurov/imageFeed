import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateProfile()
    func setAvatar()
    func tapLogout()
    func setProfileNotificationObserver()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol,
         profileLogoutService: ProfileLogoutServiceProtocol) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    func viewDidLoad() {
        updateProfile()
    }
    
    func updateProfile() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        } else {
            view?.showDefaultProfile()
            print("[viewDidLoad in ProfileViewController]: Профиль еще не загружен.")
        }
        setAvatar()
    }
    
    func setProfileNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main,
            ) { [weak self] _ in
                guard let self = self else { return }
                self.setAvatar()
            }
    }
    
    func setAvatar() {
        guard
            let avatarURL = profileImageService.avatarURL,
            let url = URL(string: avatarURL)
        else {
            view?.updateAvatar(url: nil)
            print("[setAvatar in ProfileViewPresenter]: Не удалось загрузить аватар.")
            return
        }
        view?.updateAvatar(url: url)
    }
    
    func tapLogout() {
        view?.didTapLogoutButton()
    }
}
