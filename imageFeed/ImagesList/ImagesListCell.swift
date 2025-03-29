import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Public properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var cellImage: UIImageView!
    
    func configure(with image: UIImage, date: String, isLiked: Bool) {
        cellImage.image = image
        dateLabel.text = date
        
        let likeImage = isLiked ? UIImage(named: "likeButtonOn") : UIImage(
            named: "likeButtonOff"
        )
        
        likeButton.setImage(likeImage, for: .normal)
    }
}
