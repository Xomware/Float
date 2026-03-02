import XCTest

final class BookmarkTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }

    func testBookmarkButtonExistsOnDealCard() {
        app.tabBars.buttons["Deals"].tap()
        let bookmark = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'bookmark'")
        ).firstMatch
        XCTAssertTrue(bookmark.waitForExistence(timeout: 5))
    }

    func testTapBookmarkToggle() {
        app.tabBars.buttons["Deals"].tap()
        let bookmark = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'bookmark'")
        ).firstMatch
        XCTAssertTrue(bookmark.waitForExistence(timeout: 5))
        bookmark.tap()
    }

    func testBookmarksViewSegmentedControl() {
        app.tabBars.buttons["Search"].tap()
        let nav = app.buttons["Bookmarks"]
        if nav.waitForExistence(timeout: 3) {
            nav.tap()
            XCTAssertTrue(app.buttons["Deals"].waitForExistence(timeout: 3))
            XCTAssertTrue(app.buttons["Venues"].exists)
        }
    }
}
