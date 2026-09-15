import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        
        // Given
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        let presenterSpy = ImagesListPresenterSpy()
        viewController?.configure(presenterSpy)
        
        // When
        
        _ = viewController?.view
        
        // Then
        XCTAssertEqual(
            presenterSpy.viewDidLoadCallsCount, 1,
            "ViewController должен вызвать viewDidLoad у презентера ровно один раз"
        )
    }
}

