// ExpiryAlertServiceTests.swift
// FloatTests

import XCTest
import UserNotifications
@testable import Float

// MARK: - Mock Notification Center

final class MockNotificationCenter: NotificationCenterProtocol, @unchecked Sendable {
    var authorizationGranted = true
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var allRemoved = false
    var registeredCategories: Set<UNNotificationCategory> = []

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        authorizationGranted
    }

    func notificationSettings() async -> UNNotificationSettings {
        // Can't easily construct UNNotificationSettings, so we test via requestPermission return value
        fatalError("Not used in tests — test authorizationStatus via requestPermission()")
    }

    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }

    func removeAllPendingNotificationRequests() {
        allRemoved = true
    }

    func setNotificationCategories(_ categories: Set<UNNotificationCategory>) {
        registeredCategories = categories
    }
}

// MARK: - Test Helpers

extension Deal {
    static func testDeal(
        id: UUID = UUID(),
        title: String = "Happy Hour Special",
        venueId: UUID = UUID(),
        venueName: String = "The Bar",
        expiresAt: Date? = Date().addingTimeInterval(2 * 60 * 60) // 2 hours from now
    ) -> Deal {
        Deal(
            id: id,
            title: title,
            description: "Test deal",
            category: "drink",
            venueId: venueId,
            venueName: venueName,
            expiresAt: expiresAt,
            startsAt: nil,
            discountType: "percentage",
            discountValue: 50,
            terms: nil,
            distance: nil,
            distanceFromUser: nil
        )
    }
}

// MARK: - Tests

final class ExpiryAlertServiceTests: XCTestCase {
    var mockCenter: MockNotificationCenter!
    var scheduler: NotificationScheduler!

    override func setUp() {
        super.setUp()
        mockCenter = MockNotificationCenter()
        scheduler = NotificationScheduler(center: mockCenter)

        // Ensure reminders are enabled for tests
        UserDefaults.standard.removeObject(forKey: "dealExpiryReminders")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "dealExpiryReminders")
        super.tearDown()
    }

    // MARK: - Test 1: Schedules both 60-min and 15-min notifications

    func testSchedulesBothAlerts() async {
        let deal = Deal.testDeal(expiresAt: Date().addingTimeInterval(2 * 60 * 60))

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        XCTAssertEqual(mockCenter.addedRequests.count, 2)

        let identifiers = mockCenter.addedRequests.map(\.identifier)
        XCTAssertTrue(identifiers.contains("deal-expiry-60-\(deal.id.uuidString)"))
        XCTAssertTrue(identifiers.contains("deal-expiry-15-\(deal.id.uuidString)"))
    }

    // MARK: - Test 2: Correct notification content for 60-min alert

    func testSixtyMinAlertContent() async {
        let deal = Deal.testDeal(title: "Taco Tuesday", venueName: "Casa Azul")

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        let sixtyMinRequest = mockCenter.addedRequests.first {
            $0.identifier.contains("deal-expiry-60")
        }
        XCTAssertNotNil(sixtyMinRequest)
        XCTAssertEqual(sixtyMinRequest?.content.title, "⏰ Deal expiring soon!")
        XCTAssertTrue(sixtyMinRequest?.content.body.contains("Taco Tuesday") ?? false)
        XCTAssertTrue(sixtyMinRequest?.content.body.contains("Casa Azul") ?? false)
        XCTAssertEqual(sixtyMinRequest?.content.categoryIdentifier, "DEAL_EXPIRY")
    }

    // MARK: - Test 3: Correct notification content for 15-min alert

    func testFifteenMinAlertContent() async {
        let deal = Deal.testDeal(title: "Wing Night", venueName: "The Pub")

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        let fifteenMinRequest = mockCenter.addedRequests.first {
            $0.identifier.contains("deal-expiry-15")
        }
        XCTAssertNotNil(fifteenMinRequest)
        XCTAssertEqual(fifteenMinRequest?.content.title, "🚨 Last chance!")
        XCTAssertTrue(fifteenMinRequest?.content.body.contains("Wing Night") ?? false)
        XCTAssertTrue(fifteenMinRequest?.content.body.contains("The Pub") ?? false)
    }

    // MARK: - Test 4: Deal without expiresAt doesn't schedule

    func testNoExpiresAtSkipsScheduling() async {
        let deal = Deal.testDeal(expiresAt: nil)

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        XCTAssertEqual(mockCenter.addedRequests.count, 0)
    }

    // MARK: - Test 5: Already expired deal doesn't schedule

    func testExpiredDealSkipsScheduling() async {
        let deal = Deal.testDeal(expiresAt: Date().addingTimeInterval(-60)) // expired 1 min ago

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        XCTAssertEqual(mockCenter.addedRequests.count, 0)
    }

    // MARK: - Test 6: Cancel removes correct identifiers

    func testCancelRemovesCorrectIdentifiers() async {
        let dealId = UUID()

        await scheduler.cancelAlerts(for: dealId)

        XCTAssertEqual(mockCenter.removedIdentifiers.count, 2)
        XCTAssertTrue(mockCenter.removedIdentifiers.contains("deal-expiry-60-\(dealId.uuidString)"))
        XCTAssertTrue(mockCenter.removedIdentifiers.contains("deal-expiry-15-\(dealId.uuidString)"))
    }

    // MARK: - Test 7: Only 15-min alert when expiry is within 60 min but > 15 min

    func testOnlyFifteenMinAlertWhenExpirySoon() async {
        let deal = Deal.testDeal(expiresAt: Date().addingTimeInterval(30 * 60)) // 30 min from now

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        XCTAssertEqual(mockCenter.addedRequests.count, 1)
        XCTAssertEqual(mockCenter.addedRequests.first?.identifier, "deal-expiry-15-\(deal.id.uuidString)")
    }

    // MARK: - Test 8: No alerts when expiry is within 15 min

    func testNoAlertsWhenExpiryVeryClose() async {
        let deal = Deal.testDeal(expiresAt: Date().addingTimeInterval(10 * 60)) // 10 min from now

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        XCTAssertEqual(mockCenter.addedRequests.count, 0)
    }

    // MARK: - Test 9: UserInfo contains dealId and venueId

    func testUserInfoContainsDealAndVenueIds() async {
        let dealId = UUID()
        let venueId = UUID()
        let deal = Deal.testDeal(id: dealId, venueId: venueId)

        await scheduler.scheduleDealExpiryAlerts(for: deal)

        for request in mockCenter.addedRequests {
            let userInfo = request.content.userInfo
            XCTAssertEqual(userInfo["dealId"] as? String, dealId.uuidString)
            XCTAssertEqual(userInfo["venueId"] as? String, venueId.uuidString)
        }
    }

    // MARK: - Test 10: Request permission returns grant status

    func testRequestPermissionGranted() async {
        mockCenter.authorizationGranted = true
        let granted = await scheduler.requestPermission()
        XCTAssertTrue(granted)
    }

    func testRequestPermissionDenied() async {
        mockCenter.authorizationGranted = false
        let granted = await scheduler.requestPermission()
        XCTAssertFalse(granted)
    }

    // MARK: - Test 11: Registers DEAL_EXPIRY category

    func testRegistersNotificationCategory() {
        XCTAssertEqual(mockCenter.registeredCategories.count, 1)
        XCTAssertEqual(mockCenter.registeredCategories.first?.identifier, "DEAL_EXPIRY")
    }
}
