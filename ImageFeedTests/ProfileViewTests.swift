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
        // given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "ViewController должен вызвать viewDidLoad у презентера")
    }
}
