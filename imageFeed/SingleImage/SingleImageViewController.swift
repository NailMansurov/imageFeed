import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            singleImageView.image = image
            singleImageView.frame.size = image.size
        }
    }
    var imageURL: URL?
    
    @IBOutlet private var singleImageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        //        guard let image else { return }
        //        singleImageView.image = image
        //        singleImageView.frame.size = image.size
        //        rescaleAndCenterImageInScrollView(image: image)
        
        if let image = image {
            singleImageView.image = image
            singleImageView.frame.size = image.size
            scrollView.contentSize = image.size
            rescaleAndCenterImageInScrollView(image: image)
        } else {
            loadImage()
        }
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func loadImage() {
        UIBlockingProgressHUD.show()
        
        if let url = imageURL {
            singleImageView.kf.setImage(with: url,
                                        placeholder: R.image.imagePlaceholder(),
                                        options: nil
            ) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let value):
                    self?.image = value.image
                    self?.rescaleAndCenterImageInScrollView(image: value.image)
                case .failure(let error):
                    print("[viewDidLoad] Error: \(error.localizedDescription)")
                    self?.showError()
                }
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        guard imageSize.width > 0 && imageSize.height > 0 else {
            return
        }
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView
    }
}
