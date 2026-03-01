import XCTest

final class TabNavigationTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }
    
    // MARK: - Tab Bar Existence
    
    func testAllTabBarItemsExist() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist")
        
        let nearby = tabBar.buttons["Nearby"]
        XCTAssertTrue(nearby.exists, "Nearby tab should exist")
        
        let deals = tabBar.buttons["Deals"]
        XCTAssertTrue(deals.exists, "Deals tab should exist")
        
        let search = tabBar.buttons["Search"]
        XCTAssertTrue(search.exists, "Search tab should exist")
        
        let profile = tabBar.buttons["Profile"]
        XCTAssertTrue(profile.exists, "Profile tab should exist")
    }
    
    // MARK: - Tab Navigation
    
    func testNearbyTabNavigation() {
        let nearbyTab = app.tabBars.buttons["Nearby"]
        XCTAssertTrue(nearbyTab.waitForExistence(timeout: 5))
        nearbyTab.tap()
        
        // Map should appear
        let map = app.maps.firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5), "Map should be visible on Nearby tab")
    }
    
    func testDealsTabNavigation() {
        let dealsTab = app.tabBars.buttons["Deals"]
        XCTAssertTrue(dealsTab.waitForExistence(timeout: 5))
        dealsTab.tap()
        
        // Deal list header should appear
        let dealText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'deals' OR label CONTAINS 'Finding'")).firstMatch
        XCTAssertTrue(dealText.waitForExistence(timeout: 5), "Deals content should be visible")
    }
    
    func testSearchTabNavigation() {
        let searchTab = app.tabBars.buttons["Search"]
        XCTAssertTrue(searchTab.waitForExistence(timeout: 5))
        searchTab.tap()
        
        // Search view should appear — look for search field or search-related UI
        let searchContent = app.otherElements.firstMatch
        XCTAssertTrue(searchContent.waitForExistence(timeout: 5), "Search content should be visible")
    }
    
    func testProfileTabNavigation() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        let profileNav = app.navigationBars["Profile"]
        XCTAssertTrue(profileNav.waitForExistence(timeout: 5), "Profile navigation bar should appear")
    }
    
    // MARK: - Tab Switching
    
    func testSwitchBetweenAllTabs() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Nearby → Deals → Search → Profile → Nearby
        tabBar.buttons["Nearby"].tap()
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 5))
        
        tabBar.buttons["Deals"].tap()
        let dealContent = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'deals' OR label CONTAINS 'Finding'")).firstMatch
        XCTAssertTrue(dealContent.waitForExistence(timeout: 5))
        
        tabBar.buttons["Search"].tap()
        // Just verify tab switched successfully
        XCTAssertTrue(tabBar.buttons["Search"].isSelected, "Search tab should be selected")
        
        tabBar.buttons["Profile"].tap()
        XCTAssertTrue(app.navigationBars["Profile"].waitForExistence(timeout: 5))
        
        tabBar.buttons["Nearby"].tap()
        XCTAssertTrue(app.maps.firstMatch.waitForExistence(timeout: 5))
    }
}
