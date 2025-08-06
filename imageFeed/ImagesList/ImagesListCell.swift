import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Private properties
    
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var cellImage: UIImageView!
    
    // MARK: - Overrides methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = R.image.imagePlaceholder()
    }
    
    // MARK: - Private methods
    
    @IBAction private func didTapLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    
    // MARK: - Public methods
    
    func configure(with photo: Photo) {
        cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: R.image.imagePlaceholder()
        )
        if let date = photo.createdAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            formatter.locale = Locale(identifier: "ru_RU")
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
        setIsLiked(isLiked: photo.isLiked)
    }
    
    func setIsLiked(isLiked: Bool) {
        let imageName = isLiked ? R.image.likeButtonOn() : R.image.likeButtonOff()
        likeButton.setImage(imageName, for: .normal)
    }
    
    func setLoadingIndicator(_ enabled: Bool) {
        cellImage.kf.indicatorType = enabled ? .activity: .none
    }
}
