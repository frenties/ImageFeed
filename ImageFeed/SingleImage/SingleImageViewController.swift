import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var image: UIImage?
    var largeImageURL : URL?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true,completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        guard let imageToShare = imageView.image else {return}
        
        let activityViewController = UIActivityViewController(activityItems: [imageToShare],
                                                              applicationActivities: nil
        )
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        imageView.image = image
        imageView.frame.size = image?.size ?? .zero
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadImage()
    }
    
    private func loadImage() {
        guard let largeImageURL = largeImageURL else { return }
        
        UIBlockingProgressHUD.show()
        
        
        imageView.kf.setImage(with: largeImageURL) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                
                self.imageView.frame.size = imageResult.image.size
                
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так.",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
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

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max(0, (scrollView.bounds.width - scrollView.contentSize.width) * 0.5)
        let offsetY = max(0, (scrollView.bounds.height - scrollView.contentSize.height) * 0.5)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
