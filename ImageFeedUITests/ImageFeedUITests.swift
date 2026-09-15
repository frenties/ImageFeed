import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10))
        authButton.tap()
        
        sleep(5)
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = app.textFields.element(boundBy: 0)
        if loginTextField.waitForExistence(timeout: 5.0) {
            loginTextField.tap()
            loginTextField.typeText("E-mail")
            
            let passwordTextField = app.secureTextFields.element(boundBy: 0)
            if passwordTextField.waitForExistence(timeout: 5.0) {
                passwordTextField.tap()
                passwordTextField.typeText("Password")
            }
            
            let loginButton = app.buttons["Login"]
            if loginButton.waitForExistence(timeout: 5.0) {
                loginButton.tap()
            }
        }
        
        let tableView = app.tables.element
        XCTAssertTrue(tableView.waitForExistence(timeout: 10.0), "Экран ленты картинок не загрузился")
    }
    
    func testFeed() throws {
        sleep(5)
        
        let tableView = app.tables.element
        XCTAssertTrue(tableView.waitForExistence(timeout: 10.0), "Экран ленты картинок не загрузился")
        
        tableView.swipeUp()
        sleep(2)
        
        let firstCell = tableView.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0))
        
        let likeButton = firstCell.buttons.element(boundBy: 0)
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5.0))
        likeButton.tap()
        
        sleep(3)
        
        likeButton.tap()
        sleep(3)
        
        firstCell.tap()
        
        let scrollView = app.scrollViews.element
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5.0), "Экран детального просмотра не открылся")
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5.0))
        
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        let backButton = app.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5.0))
        backButton.tap()
        
        sleep(3)
        XCTAssertTrue(tableView.waitForExistence(timeout: 5.0))
    }
    
    func testProfile() throws {
        let tableView = app.tables.element
        XCTAssertTrue(tableView.waitForExistence(timeout: 10.0))
        
        let profileTabButton = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTabButton.waitForExistence(timeout: 5.0))
        profileTabButton.tap()
        
        let nameLabel = app.staticTexts.element(boundBy: 0)
        let loginLabel = app.staticTexts.element(boundBy: 1)
        
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5.0))
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5.0))
        
        let logoutButton = app.buttons.element(boundBy: 0)
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5.0))
        logoutButton.tap()
        
        sleep(2)
        
        let logoutAlertButton = app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(logoutAlertButton.waitForExistence(timeout: 5.0))
        logoutAlertButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10.0))
    }
}
