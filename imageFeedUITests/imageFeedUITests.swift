import XCTest

final class imageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        sleep(2)
        app.buttons["Authenticate"].tap()
        
        sleep(2)
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        XCTAssertTrue(webView.isHittable)
        
        sleep (2)
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText("")
        sleep(2)
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        passwordTextField.press(forDuration: 0.5)
        
        passwordTextField.typeText("")
        webView.swipeUp()
        sleep(2)
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        sleep(2)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 3))
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons.firstMatch.tap()
        sleep(1)
        cellToLike.buttons.firstMatch.tap()
        sleep(1)
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["navBackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        if app.buttons["Authenticate"].exists {
            try testAuth()
        }
        
        let feedTable = app.tables.firstMatch
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10))
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Ivan Ivan"].exists)
        XCTAssertTrue(app.staticTexts["@zottnail"].exists)
        
        app.buttons["exit"].tap()
        
        sleep(2)
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
