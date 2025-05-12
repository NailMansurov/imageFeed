import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let avatarCornerRadius: CGFloat = 35
        static let avatarWidth: CGFloat = 70
        static let avatarHeight: CGFloat = 70
        static let avatarLeading: CGFloat = 16
        static let avatarTop: CGFloat = 32
        
        static let nameLabelFontSize: CGFloat = 23
        static let nameLabelTrailing: CGFloat = 16
        static let nameLabelTop: CGFloat = 8
        
        static let loginLabelFontSize: CGFloat = 13
        static let loginLabelTop: CGFloat = 8
        
        static let descriptionLabelFontSize: CGFloat = 13
        static let desriptionLabelTop: CGFloat = 8
        
        static let logoutButtonWidth: CGFloat = 44
        static let logoutButtonHeight: CGFloat = 44
        static let logoutButtonTrailing: CGFloat = -16
    }
    
    // MARK: - Private properties
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: R.image.avatarPhoto())
        imageView.layer.cornerRadius = Constants.avatarCornerRadius
        imageView.layer.masksToBounds = true
        view.addSubview(imageView)
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = R.color.ypWhite()
        label.font = .systemFont(ofSize: Constants.nameLabelFontSize, weight: .bold)
        view.addSubview(label)
        return label
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = R.color.ypGrey()
        label.font = .systemFont(ofSize: Constants.loginLabelFontSize)
        view.addSubview(label)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = R.color.ypWhite()
        label.font = .systemFont(ofSize: Constants.descriptionLabelFontSize)
        view.addSubview(label)
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.logoutButton(), for: .normal)
        view.addSubview(button)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.addSubviews(
            avatarImageView,
            nameLabel,
            loginLabel,
            descriptionLabel,
            logoutButton
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.avatarLeading
            ),
            avatarImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.avatarTop
            ),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarWidth),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarHeight),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.nameLabelTrailing),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.nameLabelTop),
            
            loginLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.loginLabelTop),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: loginLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: Constants.desriptionLabelTop),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.logoutButtonTrailing),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.logoutButtonWidth),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.logoutButtonHeight)
        ])
    }
}

// MARK: - Extensions

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}
