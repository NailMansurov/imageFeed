import UIKit
import Kingfisher

struct ProfileImage: Codable {
    let small: String
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init(){}
    
    private(set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProvideDidChange")
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NSError(domain: "TokenError", code: 401, userInfo: nil)
            print("[fetchProfileImageURL]: Неверный токен \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        let urlString = "https://api.unsplash.com/users/\(username)"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "URLStringError", code: 400, userInfo: nil)
            print("[fetchProfileImageURL]: Неверный URL \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    self?.avatarURL = userResult.profileImage.small
                    completion(.success(userResult.profileImage.small))
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
                case .failure(let error):
                    print("[fetchProfileImageURL]: Не удалось получить URL аватара пользователя \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    func fetchAvatarURL(into imageView: UIImageView) {
        guard let imageURLString = avatarURL, let imageURL = URL(string: imageURLString) else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 100)
        
        DispatchQueue.main.async {
            imageView.kf.setImage(with: imageURL,
                                  placeholder: R.image.placeholder(),
                                  options: [.processor(processor)]) { result in
                switch result {
                case .success(_):
                    print("[fetchAvatarURL]: Изображение пользователя загружено")
                case .failure(let error):
                    print("[fetchAvatarURL]: Ошибка при загрузке Изображения пользователя: \(error)")
                }
            }
        }
    }
}
