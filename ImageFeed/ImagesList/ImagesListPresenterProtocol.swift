import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    
    func calculateCellHeight(at index: Int, tableViewWidth: Double) -> Double
    func formatPhotoDate(at index: Int) -> String?
    func willDisplayCell(at index: Int)
    func cellLikeButtonTapped(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void)
}
