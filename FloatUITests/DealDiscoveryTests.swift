import XCTest

final class DealDiscoveryTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }
    
    // MARK: - Map Tab
    
    func testMapTabLoads() {
        let nearbyTab = app.tabBars.buttons["Nearby"]
        XCTAssertTrue(nearbyTab.waitForExistence(timeout: 5), "Nearby tab should exist")
        nearbyTab.tap()
        
        // Map should be visible
        let map = app.maps.firstMatch
        XCTAssertTrue(map.waitForExistence(timeout: 5), "Map should be displayed on Nearby tab")
    }
    
    func testActiveNowFilterToggle() {
        let nearbyTab = app.tabBars.buttons["Nearby"]
        XCTAssertTrue(nearbyTab.waitForExistence(timeout: 5))
        nearbyTab.tap()
        
        let activeNowButton = app.buttons["Active Now"]
        XCTAssertTrue(activeNowButton.waitForExistence(timeout: 5), "Active Now filter button should exist")
        activeNowButton.tap()
    }
    
    // MARK: - Deal List Tab
    
    func testDealListTabLoads() {
        let dealsTab = app.tabBars.buttons["Deals"]
        XCTAssertTrue(dealsTab.waitForExistence(timeout: 5), "Deals tab should exist")
        dealsTab.tap()
        
        // Should show deal count or loading text
        let dealCount = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'deals near you' OR label CONTAINS 'Finding deals'")).firstMatch
        XCTAssertTrue(dealCount.waitForExistence(timeout: 5), "Deal count or loading text should appear")
    }
    
    func testDealListHasSortButton() {
        let dealsTab = app.tabBars.buttons["Deals"]
        XCTAssertTrue(dealsTab.waitForExistence(timeout: 5))
        dealsTab.tap()
        
        let sortButton = app.buttons["Sort deals"]
        XCTAssertTrue(sortButton.waitForExistence(timeout: 5), "Sort button should be accessible")
    }
    
    func testFilterPanelOpensAndCloses() {
        let dealsTab = app.tabBars.buttons["Deals"]
        XCTAssertTrue(dealsTab.waitForExistence(timeout: 5))
        dealsTab.tap()
        
        // Tap filter button
        let filterButton = app.buttons["filterDealsButton"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5), "Filter button should exist")
        filterButton.tap()
        
        // Filter sheet should appear
        let filterTitle = app.staticTexts["Filter Deals"]
        XCTAssertTrue(filterTitle.waitForExistence(timeout: 3), "Filter panel should open with title")
        
        // Verify filter sections exist
        let categorySection = app.staticTexts["Category"]
        XCTAssertTrue(categorySection.exists, "Category filter section should exist")
        
        let distanceSection = app.staticTexts["Max Distance"]
        XCTAssertTrue(distanceSection.exists, "Distance filter section should exist")
        
        // Close filter panel
        let applyButton = app.buttons["Apply"]
        XCTAssertTrue(applyButton.exists, "Apply button should exist")
        applyButton.tap()
        
        // Filter panel should dismiss
        XCTAssertFalse(filterTitle.waitForExistence(timeout: 2), "Filter panel should be dismissed")
    }
    
    func testFilterResetButton() {
        let dealsTab = app.tabBars.buttons["Deals"]
        XCTAssertTrue(dealsTab.waitForExistence(timeout: 5))
        dealsTab.tap()
        
        let filterButton = app.buttons["filterDealsButton"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 5))
        filterButton.tap()
        
        let resetButton = app.buttons["Reset"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 3), "Reset button should exist in filter panel")
    }
}
