import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

enum FeedCellImageState {
    case loading
    case error
    case success(UIImage)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    private let skeletonView = GradientView()
    
    // MARK: - IB Outlets
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSkeletonView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
        skeletonView.isHidden = true
    }
    
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImageName = isLiked ? "active" : "noactive"
        if let likeImage = UIImage(named: likeImageName) {
            likeButton.setImage(likeImage, for: .normal)
        }
    }
    
    private func setupSkeletonView() {
        skeletonView.setCornerRadius(16)
        skeletonView.isHidden = true
        
        skeletonView.translatesAutoresizingMaskIntoConstraints = false
        
        cellImageView.addSubview(skeletonView)
        
        NSLayoutConstraint.activate([
            skeletonView.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            skeletonView.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor),
            skeletonView.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            skeletonView.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor)
        ])
    }
    
    
    
    func render(state: FeedCellImageState) {
        switch state {
        case .loading:
            skeletonView.isHidden = false
            cellImageView.image = nil
            
        case .error:
            skeletonView.isHidden = true
            
            cellImageView.image = UIImage(resource: .stub)
            
        case .success(let image):
            skeletonView.isHidden = true
            cellImageView.image = image
        }
    }
    
    private var gradientLayers: [CAGradientLayer] = []
    
    func configure(with url: URL) {
        
        render(state: .loading)
        
        cellImageView.kf.setImage(with: url) { [weak self] result  in
            guard let self else { return }
            
            switch result {
            case .success(let value):
                self.render(state: .success(value.image))
            case .failure(_):
                self.render(state: .error)
            }
        }
    }
    
    private func removeGradient() {
        
        gradientLayers.forEach { $0.removeFromSuperlayer() }
        gradientLayers.removeAll()
    }
}
