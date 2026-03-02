import XCTest

final class TabNavigationTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }

    func testAllTabBarItemsExist() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.buttons["Nearby"].exists)
        XCTAssertTrue(tabBar.buttons["Deals"].exists)
        XCTAssertTrue(tabBar.buttons["Search"].exists)
        XCTAssertTrue(tabBar.buttons["Profile"].exists)
    }

    func testNearbyTabShowsMap() {
        app.tabBars.buttons["Nearby"].tap()
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 5))
    }

    func testDealsTabShowsContent() {
        app.tabBars.buttons["Deals"].tap()
        let text = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'deals' OR label CONTAINS 'Finding'")
        ).firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 5))
    }

    func testProfileTabShowsNavBar() {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
    }

    func testSwitchBetweenAllTabs() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        tabBar.buttons["Nearby"].tap()
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 5))

        tabBar.buttons["Deals"].tap()
        let deals = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'deals' OR label CONTAINS 'Finding'")
        ).firstMatch
        XCTAssertTrue(deals.waitForExistence(timeout: 5))

        tabBar.buttons["Search"].tap()
        XCTAssertTrue(tabBar.buttons["Search"].isSelected)

        tabBar.buttons["Profile"].tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))

        tabBar.buttons["Nearby"].tap()
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 5))
    }
}
