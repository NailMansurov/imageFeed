import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    func insertRows(from oldCount: Int, to newCount: Int)
    func reloadCell(at indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Public properties
    
    var presenter: ImagesListViewPresenterProtocol?
    
    // MARK: - Private properties
    
    @IBOutlet var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "image\($0)" }
    private let showSingleImageSequeIdentifier = "ShowSingleImage"
    private let currentDate = Date()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
        
        if presenter == nil {
            presenter = ImagesListViewPresenter(
                view: self,
                imagesListService: ImagesListService.shared
            )
        }
        presenter?.viewDidLoad()
    }
    
    // MARK: - Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSequeIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath,
           let photo = presenter?.photo(at: indexPath) {
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
    
    // MARK: - Public methods
    
    func insertRows(from oldCount: Int, to newCount: Int) {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    func reloadCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell,
              let photo = presenter?.photo(at: indexPath) else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: photo)
        
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with photo: Photo) {
        cell.configure(with: photo)
        cell.delegate = self
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(
            withIdentifier: showSingleImageSequeIdentifier,
            sender: indexPath
        )
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath) else { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let ratio = imageViewWidth / photo.size.width
        return photo.size.height * ratio + imageInsets.top + imageInsets.bottom
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        UIBlockingProgressHUD.show()
        presenter?.didTapLike(at: indexPath) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                self.reloadCell(at: indexPath)
            case .failure:
                let alert = UIAlertController(title: "Что-то пошло не так(",
                                              message: "Ошибка при установке/снятии лайка",
                                              preferredStyle: .alert
                )
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }
}

