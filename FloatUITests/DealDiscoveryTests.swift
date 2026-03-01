import XCTest

final class DealDiscoveryTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }

    func testMapTabLoads() {
        app.tabBars.buttons["Nearby"].tap()
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 5))
    }

    func testActiveNowFilterToggle() {
        app.tabBars.buttons["Nearby"].tap()
        let btn = app.buttons["Active Now"]
        XCTAssertTrue(btn.waitForExistence(timeout: 5))
        btn.tap()
    }

    func testDealListTabLoads() {
        app.tabBars.buttons["Deals"].tap()
        let header = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'deals near you' OR label CONTAINS 'Finding deals'")
        ).firstMatch
        XCTAssertTrue(header.waitForExistence(timeout: 5))
    }

    func testDealListHasSortButton() {
        app.tabBars.buttons["Deals"].tap()
        XCTAssertTrue(app.buttons["Sort deals"].waitForExistence(timeout: 5))
    }

    func testFilterPanelOpensAndCloses() {
        app.tabBars.buttons["Deals"].tap()
        app.buttons["filterDealsButton"].tap()

        XCTAssertTrue(app.staticTexts["Filter Deals"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Category"].exists)
        XCTAssertTrue(app.staticTexts["Max Distance"].exists)

        app.buttons["Apply"].tap()
        XCTAssertFalse(app.staticTexts["Filter Deals"].waitForExistence(timeout: 2))
    }

    func testFilterResetButton() {
        app.tabBars.buttons["Deals"].tap()
        app.buttons["filterDealsButton"].tap()
        XCTAssertTrue(app.buttons["Reset"].waitForExistence(timeout: 3))
    }
}
