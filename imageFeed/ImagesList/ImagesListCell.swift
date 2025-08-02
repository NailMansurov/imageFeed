import UIKit

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
            
//        fullsizeImageView.kf.cancelDownLoadTask()
    }
    
    // MARK: - Public methods
    
    func configure(with photo: Photo) {
        cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "image_placeholder")
        )
        if let date = photo.createdAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            formatter.locale = Locale(identifier: "ru_RU")
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
//        setLikeButtonImage(isLiked: photo.isLiked)
//        setupGradient()
    }
}
