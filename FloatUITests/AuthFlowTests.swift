import XCTest

final class AuthFlowTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    // MARK: - Sign In Screen Appearance
    
    func testSignInScreenAppearsOnLaunch() {
        // The app should show the sign-in screen when not authenticated
        let floatTitle = app.staticTexts["Float"]
        XCTAssertTrue(floatTitle.waitForExistence(timeout: 5), "Float title should appear on sign-in screen")
        
        let subtitle = app.staticTexts["Real-time deals at bars & restaurants near you"]
        XCTAssertTrue(subtitle.exists, "Subtitle should be visible on sign-in screen")
    }
    
    func testSignInScreenHasAppleSignInButton() {
        let appleButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(appleButton.waitForExistence(timeout: 5), "Sign in with Apple button should exist")
    }
    
    func testSignInScreenHasGoogleSignInButton() {
        let googleButton = app.buttons["Continue with Google"]
        XCTAssertTrue(googleButton.waitForExistence(timeout: 5), "Continue with Google button should exist")
    }
    
    func testSignInScreenHasEmailOption() {
        let emailButton = app.buttons["Sign in with Email"]
        XCTAssertTrue(emailButton.waitForExistence(timeout: 5), "Sign in with Email button should exist")
    }
    
    func testEmailFieldsAppearWhenTapped() {
        let emailButton = app.buttons["Sign in with Email"]
        XCTAssertTrue(emailButton.waitForExistence(timeout: 5))
        emailButton.tap()
        
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 3), "Email text field should appear")
        
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 3), "Password field should appear")
        
        let signInButton = app.buttons["Sign In with Email"]
        XCTAssertTrue(signInButton.exists, "Sign In with Email submit button should appear")
    }
    
    func testCreateAccountLinkExists() {
        let createAccount = app.buttons["Create account"]
        XCTAssertTrue(createAccount.waitForExistence(timeout: 5), "Create account link should exist")
    }
    
    func testHeroIconDisplayed() {
        // The wine glass icon should be visible
        let heroIcon = app.images["signIn_heroIcon"]
        XCTAssertTrue(heroIcon.waitForExistence(timeout: 5), "Hero icon should be displayed")
    }
}
