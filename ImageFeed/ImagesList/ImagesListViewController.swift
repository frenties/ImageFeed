import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol!
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presenter == nil {
            configure(ImagesListPresenter())
        }
        
        configureTableView()
        presenter.viewDidLoad()
        
    }
    // MARK: - Private Methods
    private func configureTableView() {
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == showSingleImageSegueIdentifier else {
                  super.prepare(for: segue, sender: sender)
                  return
              }
        
        guard
            let viewController = segue.destination as? SingleImageViewController,
            let indexPath = sender as? IndexPath
        else {
            assertionFailure("Failed to prepare for ShowSingleImage")
            return
        }

        let photo = presenter.photo(at: indexPath.row)

        if let url = URL(string: photo.largeImageURL) {
            viewController.largeImageURL = url
        }

        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            viewController.image = cell.cellImageView.image
        }
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else {
            tableView.reloadData()
            return
        }
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    
    // MARK: - Public Methods
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photo(at: indexPath.row)
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        cell.dateLabel.text = presenter.formatPhotoDate(at: indexPath.row)
        cell.setIsLiked(isLiked: photo.isLiked)
        cell.configure(with: url)
        
        cell.layoutIfNeeded()
    }
}
// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return presenter.photosCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(presenter.calculateCellHeight(at: indexPath.row, tableViewWidth: Double(tableView.bounds.width)))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        presenter.willDisplayCell(at: indexPath.row)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        UIBlockingProgressHUD.show()
        
        presenter.cellLikeButtonTapped(at: indexPath.row) { [weak cell] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let isLiked):
                cell?.setIsLiked(isLiked: isLiked)
            case .failure(let error):
                print("[imageListCellDidTapLike Error]: \(error.localizedDescription)")
            }
        }
    }
}
