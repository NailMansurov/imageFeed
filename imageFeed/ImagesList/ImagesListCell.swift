import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Public properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
}
