import XCTest
@testable import Float

@MainActor
final class FriendActivityViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = FriendActivityViewModel()
        XCTAssertTrue(vm.activityItems.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.hasLoaded)
        XCTAssertFalse(vm.isEmpty)
    }

    func testIsEmptyRequiresHasLoaded() {
        let vm = FriendActivityViewModel()
        XCTAssertFalse(vm.isEmpty)
    }

    func testOptimisticLikeToggle() {
        let vm = FriendActivityViewModel()
        vm.activityItems = [makeItem(isLiked: false, likeCount: 3)]
        vm.activityItems[0].isLiked.toggle()
        vm.activityItems[0].likeCount += 1
        XCTAssertTrue(vm.activityItems[0].isLiked)
        XCTAssertEqual(vm.activityItems[0].likeCount, 4)
        vm.activityItems[0].isLiked.toggle()
        vm.activityItems[0].likeCount -= 1
        XCTAssertFalse(vm.activityItems[0].isLiked)
        XCTAssertEqual(vm.activityItems[0].likeCount, 3)
    }

    func testActivityVisibilityDisplayNames() {
        XCTAssertEqual(ActivityVisibility.public.displayName, "Everyone")
        XCTAssertEqual(ActivityVisibility.friends.displayName, "Friends Only")
        XCTAssertEqual(ActivityVisibility.private.displayName, "Only Me")
    }

    func testActivityVisibilityIcons() {
        XCTAssertEqual(ActivityVisibility.public.icon, "globe")
        XCTAssertEqual(ActivityVisibility.friends.icon, "person.2.fill")
        XCTAssertEqual(ActivityVisibility.private.icon, "lock.fill")
    }

    func testActivityVisibilityCodable() throws {
        for v in ActivityVisibility.allCases {
            let data = try JSONEncoder().encode(v)
            XCTAssertEqual(try JSONDecoder().decode(ActivityVisibility.self, from: data), v)
        }
    }

    func testFriendConnectionDecoding() throws {
        let json = #"{"id":"550e8400-e29b-41d4-a716-446655440000","requester_id":"550e8400-e29b-41d4-a716-446655440001","addressee_id":"550e8400-e29b-41d4-a716-446655440002","status":"pending","created_at":"2026-03-01T12:00:00Z"}"#
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601
        let c = try d.decode(FriendConnection.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(c.status, .pending)
        XCTAssertEqual(c.requesterId, UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001"))
    }

    func testFriendStatusValues() {
        XCTAssertEqual(FriendStatus.pending.rawValue, "pending")
        XCTAssertEqual(FriendStatus.accepted.rawValue, "accepted")
        XCTAssertEqual(FriendStatus.declined.rawValue, "declined")
    }

    func testActivityLikeDecoding() throws {
        let json = #"{"id":"550e8400-e29b-41d4-a716-446655440000","user_id":"550e8400-e29b-41d4-a716-446655440001","redemption_id":"550e8400-e29b-41d4-a716-446655440002","created_at":"2026-03-01T12:00:00Z"}"#
        let d = JSONDecoder(); d.dateDecodingStrategy = .iso8601
        let like = try d.decode(ActivityLike.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(like.userId, UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001"))
    }

    // MARK: - Helpers

    private func makeItem(isLiked: Bool, likeCount: Int) -> FriendActivityItem {
        FriendActivityItem(id: UUID(), userId: UUID(), username: "test", displayName: "Test",
                           avatarUrl: nil, dealId: UUID(), dealTitle: "Deal", venueName: "Venue",
                           redeemedAt: Date(), redemptionId: UUID(), isLiked: isLiked, likeCount: likeCount)
    }
}
