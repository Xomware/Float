import XCTest

final class ProfileTests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }
    
    // MARK: - Profile Tab
    
    func testProfileTabNavigates() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Profile tab should exist")
        profileTab.tap()
        
        let profileTitle = app.navigationBars["Profile"]
        XCTAssertTrue(profileTitle.waitForExistence(timeout: 5), "Profile navigation title should appear")
    }
    
    func testProfileShowsUserInfo() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        // Should show user display name or loading skeleton
        let displayName = app.staticTexts["Float User"]
        let skeleton = app.otherElements["profileSkeleton"]
        XCTAssertTrue(displayName.waitForExistence(timeout: 5) || skeleton.exists,
                     "Profile should show user name or loading state")
    }
    
    func testProfileShowsStats() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        // Wait for profile to load
        let redeemedStat = app.staticTexts["Redeemed"]
        XCTAssertTrue(redeemedStat.waitForExistence(timeout: 5), "Redeemed stat should be displayed")
        
        let savedStat = app.staticTexts["Saved"]
        XCTAssertTrue(savedStat.exists, "Saved stat should be displayed")
        
        let memberStat = app.staticTexts["Member"]
        XCTAssertTrue(memberStat.exists, "Member stat should be displayed")
    }
    
    func testProfileHasSettingsButton() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist in profile")
    }
    
    func testProfileHasEditButton() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        let editButton = app.buttons["Edit Profile"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5), "Edit Profile button should exist")
    }
    
    func testProfileShowsRedemptionHistory() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        let redemptionsHeader = app.staticTexts["Recent Redemptions"]
        XCTAssertTrue(redemptionsHeader.waitForExistence(timeout: 5), "Recent Redemptions section should exist")
    }
    
    func testProfileHasSignOutOption() {
        let profileTab = app.tabBars.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        // Scroll down to find sign out
        let signOutButton = app.buttons["Sign Out"]
        XCTAssertTrue(signOutButton.waitForExistence(timeout: 5), "Sign Out button should exist")
    }
}
