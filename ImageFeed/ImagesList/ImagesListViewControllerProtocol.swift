import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol! { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadTableView()
}
