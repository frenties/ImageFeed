@testable import ImageFeed
import XCTest
import Foundation

// MARK: - WebViewTests
final class WebViewTests: XCTestCase {
    
    private var authHelper: AuthHelper!
    private var presenter: WebViewPresenter!
    
    override func setUp() {
        super.setUp()
        
        authHelper = AuthHelper()
        presenter = WebViewPresenter(authHelper: authHelper)
    }
    
    
    override func tearDown() {
        presenter = nil
        authHelper = nil
        
        super.tearDown()
    }
    func testViewControllerCallsViewDidLoad() {
        
        // Given
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        
        _ = viewController.view
        
        // Then
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        
        // Given
        
        let viewController = WebViewViewControllerSpy()
        
        presenter.view = viewController
        viewController.presenter = presenter
        
        // When
        
        presenter.viewDidLoad()
        
        // Then
        
        XCTAssertTrue(viewController.loadCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // Given
   
        let progress: Float = 0.6
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // Then
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        
        // Given
        
        let progress: Float = 1.0
        
        // When
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // Then
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        
        // Given
        
        let configuration = AuthConfiguration.standard
        
        // When
        
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        // Then
        
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        
        // Given
        
        let configuration = AuthConfiguration.standard
        
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        
        guard let url = urlComponents?.url else {
            XCTFail("Failed to create URL from components")
            return
        }
        
        // When
        
        let code = authHelper.code(from: url)
        
        // Then
        
        XCTAssertEqual(code, "test code")
    }
}
