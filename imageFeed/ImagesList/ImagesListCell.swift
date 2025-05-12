import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Private properties
    
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var cellImage: UIImageView!
    
    // MARK: - Public methods
    
    func configure(with image: UIImage, date: String, isLiked: Bool) {
        cellImage.image = image
        dateLabel.text = date
        
        let likeImage = isLiked ? UIImage(named: "likeButtonOn") : UIImage(
            named: "likeButtonOff"
        )
        
        likeButton.setImage(likeImage, for: .normal)
    }
}
