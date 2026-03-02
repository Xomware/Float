import XCTest

final class ProfileTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }

    func testProfileTabNavigates() {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    func testProfileShowsUserInfo() {
        app.tabBars.buttons["Profile"].tap()
        let name = app.staticTexts["Float User"]
        XCTAssertTrue(name.waitForExistence(timeout: 5), "Should show user display name")
    }

    func testProfileShowsStats() {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Redeemed"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Saved"].exists)
        XCTAssertTrue(app.staticTexts["Member"].exists)
    }

    func testProfileHasSettingsButton() {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 5))
    }

    func testProfileHasEditButton() {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons["Edit Profile"].waitForExistence(timeout: 5))
    }

    func testProfileShowsRedemptionHistory() {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Recent Redemptions"].waitForExistence(timeout: 5))
    }

    func testProfileHasSignOutOption() {
        app.tabBars.buttons["Profile"].tap()
        let signOut = app.buttons["Sign Out"]
        XCTAssertTrue(signOut.waitForExistence(timeout: 5))
    }
}
