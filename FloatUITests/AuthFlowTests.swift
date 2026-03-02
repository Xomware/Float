import XCTest

final class AuthFlowTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testSignInScreenAppearsOnLaunch() {
        let title = app.staticTexts["Float"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))

        let subtitle = app.staticTexts["Real-time deals at bars & restaurants near you"]
        XCTAssertTrue(subtitle.exists)
    }

    func testSignInScreenHasAppleButton() {
        XCTAssertTrue(app.buttons["Sign in with Apple"].waitForExistence(timeout: 5))
    }

    func testSignInScreenHasGoogleButton() {
        XCTAssertTrue(app.buttons["Continue with Google"].waitForExistence(timeout: 5))
    }

    func testEmailFieldsAppearWhenTapped() {
        let toggle = app.buttons["Sign in with Email"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        toggle.tap()

        XCTAssertTrue(app.textFields["Email"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.secureTextFields["Password"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Sign In with Email"].exists)
    }

    func testCreateAccountLinkExists() {
        XCTAssertTrue(app.buttons["Create account"].waitForExistence(timeout: 5))
    }

    func testHeroIconDisplayed() {
        XCTAssertTrue(app.images["signIn_heroIcon"].waitForExistence(timeout: 5))
    }
}
