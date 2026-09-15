import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {}
}

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy)
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "ViewController должен вызвать viewDidLoad у презентера")
    }
}
