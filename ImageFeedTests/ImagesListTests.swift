import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "ViewController должен вызвать viewDidLoad у презентера")
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
    var photosCount: Int = 0
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func photo(at index: Int) -> Photo {
        return Photo(
            id: "1",
            size: .zero,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
    }
    
    func calculateCellHeight(at index: Int, tableViewWidth: Double) -> Double {
        return 200.0
    }
    
    func formatPhotoDate(at index: Int) -> String? {
        return "14 августа 2026"
    }
    
    func willDisplayCell(at index: Int) {}
    
    func cellLikeButtonTapped(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {}
}

