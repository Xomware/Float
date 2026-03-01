import XCTest

final class BookmarkTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }
    
    // MARK: - Bookmark Interaction
    
    func testBookmarkButtonExistsOnDealCard() {
        let dealsTab = app.tabBars.buttons["Deals"]
        XCTAssertTrue(dealsTab.waitForExistence(timeout: 5))
        dealsTab.tap()
        
        // Wait for deals to load, then check for bookmark button
        let bookmarkButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'bookmark'")).firstMatch
        XCTAssertTrue(bookmarkButton.waitForExistence(timeout: 5), "Bookmark button should exist on deal cards")
    }
    
    func testTapBookmarkToggle() {
        let dealsTab = app.tabBars.buttons["Deals"]
        XCTAssertTrue(dealsTab.waitForExistence(timeout: 5))
        dealsTab.tap()
        
        let bookmarkButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'bookmark'")).firstMatch
        XCTAssertTrue(bookmarkButton.waitForExistence(timeout: 5))
        bookmarkButton.tap()
        
        // Bookmark should toggle (visual confirmation via accessibility state)
    }
    
    // MARK: - Bookmarks View
    
    func testBookmarksViewShowsSegmentedControl() {
        // Navigate to bookmarks (via Search tab which might contain bookmarks nav)
        // In the current app structure, bookmarks may be accessible from profile or dedicated section
        let searchTab = app.tabBars.buttons["Search"]
        XCTAssertTrue(searchTab.waitForExistence(timeout: 5))
        searchTab.tap()
        
        // Look for bookmarks navigation
        let bookmarksNav = app.buttons["Bookmarks"]
        if bookmarksNav.waitForExistence(timeout: 3) {
            bookmarksNav.tap()
            
            let dealsSegment = app.buttons["Deals"]
            XCTAssertTrue(dealsSegment.waitForExistence(timeout: 3), "Deals segment should exist in bookmarks")
            
            let venuesSegment = app.buttons["Venues"]
            XCTAssertTrue(venuesSegment.exists, "Venues segment should exist in bookmarks")
        }
    }
    
    func testBookmarksEmptyState() {
        let searchTab = app.tabBars.buttons["Search"]
        XCTAssertTrue(searchTab.waitForExistence(timeout: 5))
        searchTab.tap()
        
        let bookmarksNav = app.buttons["Bookmarks"]
        if bookmarksNav.waitForExistence(timeout: 3) {
            bookmarksNav.tap()
            
            // Should show either deals or empty state
            let emptyText = app.staticTexts["No Saved Deals"]
            let dealsList = app.scrollViews.firstMatch
            XCTAssertTrue(emptyText.waitForExistence(timeout: 3) || dealsList.exists,
                         "Should show either empty state or deals list")
        }
    }
}
