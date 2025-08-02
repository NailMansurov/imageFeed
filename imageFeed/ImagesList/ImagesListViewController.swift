import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Public properties
    var photos: [Photo] = []
    var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Private properties
    
    @IBOutlet private var tableView: UITableView!
    
    private let photosName: [String] = Array(0..<20).map{ "image\($0)" }
    private let showSingleImageSequeIdentifier = "ShowSingleImage"
    private let currentDate = Date()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru-Ru")
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
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateTableViewAnimated()
        }
        
        if photos.isEmpty {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    @objc private func handlePhotosUpdate() {
        updateTableViewAnimated()
    }
    
    // MARK: - Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        UIStatusBarStyle.lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSequeIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        }
    }
    
    // MARK: - Public methods
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos
        let uniqueNewPhotos = newCount.filter { newPhoto in
            !photos.contains(where: { $0.id == newPhoto.id })
        }
        
        guard !uniqueNewPhotos.isEmpty else { return }
        
        photos.append(contentsOf: uniqueNewPhotos)
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<photos.count).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - Extensions

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: photos[indexPath.row])
        
//        imageListCell.setupGradient()
        
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with photo: Photo) {
        cell.configure(with: photo)
//        cell.delegate = self
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
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
                let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
                let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
                let ratio = imageViewWidth / photo.size.width
                return photo.size.height * ratio + imageInsets.top + imageInsets.bottom
    }
    
}
