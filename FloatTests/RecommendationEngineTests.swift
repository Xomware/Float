import XCTest
import CoreLocation
@testable import Float

final class RecommendationEngineTests: XCTestCase {

    // MARK: - Helpers

    private func makeDeal(
        id: UUID = UUID(),
        category: String = "drink",
        venueId: UUID = UUID(),
        venueName: String? = "Test Venue",
        expiresAt: Date? = Date().addingTimeInterval(86400),
        startsAt: Date? = Date(),
        distanceFromUser: Double? = 1000
    ) -> Deal {
        Deal(
            id: id,
            title: "Test Deal",
            description: "A test deal",
            category: category,
            venueId: venueId,
            venueName: venueName,
            expiresAt: expiresAt,
            startsAt: startsAt,
            discountType: "percentage",
            discountValue: 20,
            terms: nil,
            distance: distanceFromUser,
            distanceFromUser: distanceFromUser
        )
    }

    private let emptyHistory = RecommendationEngine.UserHistory(
        redeemedDealIds: [],
        redeemedCategories: [],
        redeemedVenueIds: [],
        redeemedDealTitles: [:],
        redeemedVenueNames: [:]
    )

    // MARK: - Test: Empty history returns zero score

    func testEmptyHistoryReturnsZeroScore() {
        let deal = makeDeal(
            expiresAt: Date().addingTimeInterval(86400), // far future
            startsAt: Date().addingTimeInterval(-86400 * 2), // posted 2 days ago
            distanceFromUser: 2000 // > 0.5 miles
        )

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: emptyHistory,
            userBookmarks: [],
            userRatings: [],
            userLocation: nil
        )

        XCTAssertEqual(score, 0, "Empty history with no matching factors should score 0")
    }

    // MARK: - Test: Category match adds 25 points

    func testCategoryMatchScores25() {
        let deal = makeDeal(
            category: "drink",
            expiresAt: Date().addingTimeInterval(86400),
            startsAt: Date().addingTimeInterval(-86400 * 2),
            distanceFromUser: 2000
        )

        let history = RecommendationEngine.UserHistory(
            redeemedDealIds: [UUID()],
            redeemedCategories: ["drink"],
            redeemedVenueIds: [],
            redeemedDealTitles: [:],
            redeemedVenueNames: [:]
        )

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: history,
            userBookmarks: [],
            userRatings: [],
            userLocation: nil
        )

        XCTAssertEqual(score, 25)
    }

    // MARK: - Test: Venue visit adds 20 points

    func testVenueVisitScores20() {
        let venueId = UUID()
        let deal = makeDeal(
            category: "food", // different category
            venueId: venueId,
            expiresAt: Date().addingTimeInterval(86400),
            startsAt: Date().addingTimeInterval(-86400 * 2),
            distanceFromUser: 2000
        )

        let history = RecommendationEngine.UserHistory(
            redeemedDealIds: [],
            redeemedCategories: [],
            redeemedVenueIds: [venueId],
            redeemedDealTitles: [:],
            redeemedVenueNames: [:]
        )

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: history,
            userBookmarks: [],
            userRatings: [],
            userLocation: nil
        )

        XCTAssertEqual(score, 20)
    }

    // MARK: - Test: High rating adds 15 points

    func testHighRatingScores15() {
        let dealId = UUID()
        let deal = makeDeal(
            id: dealId,
            expiresAt: Date().addingTimeInterval(86400),
            startsAt: Date().addingTimeInterval(-86400 * 2),
            distanceFromUser: 2000
        )

        let ratings = [
            RecommendationEngine.UserRating(dealId: dealId, rating: 4.5)
        ]

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: emptyHistory,
            userBookmarks: [],
            userRatings: ratings,
            userLocation: nil
        )

        XCTAssertEqual(score, 15)
    }

    // MARK: - Test: Low rating does NOT add points

    func testLowRatingScoresZero() {
        let dealId = UUID()
        let deal = makeDeal(
            id: dealId,
            expiresAt: Date().addingTimeInterval(86400),
            startsAt: Date().addingTimeInterval(-86400 * 2),
            distanceFromUser: 2000
        )

        let ratings = [
            RecommendationEngine.UserRating(dealId: dealId, rating: 3.0)
        ]

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: emptyHistory,
            userBookmarks: [],
            userRatings: ratings,
            userLocation: nil
        )

        XCTAssertEqual(score, 0)
    }

    // MARK: - Test: Urgency (expiring within 2 hours) adds 20 points

    func testUrgencyScores20() {
        let deal = makeDeal(
            expiresAt: Date().addingTimeInterval(3600), // 1 hour from now
            startsAt: Date().addingTimeInterval(-86400 * 2),
            distanceFromUser: 2000
        )

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: emptyHistory,
            userBookmarks: [],
            userRatings: [],
            userLocation: nil
        )

        XCTAssertEqual(score, 20)
    }

    // MARK: - Test: Proximity (< 0.5 miles) adds 10 points

    func testProximityScores10() {
        let deal = makeDeal(
            expiresAt: Date().addingTimeInterval(86400),
            startsAt: Date().addingTimeInterval(-86400 * 2),
            distanceFromUser: 500 // < 805m
        )

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: emptyHistory,
            userBookmarks: [],
            userRatings: [],
            userLocation: nil
        )

        XCTAssertEqual(score, 10)
    }

    // MARK: - Test: New deal (posted in last 24h) adds 10 points

    func testNewDealScores10() {
        let deal = makeDeal(
            expiresAt: Date().addingTimeInterval(86400),
            startsAt: Date().addingTimeInterval(-3600), // posted 1 hour ago
            distanceFromUser: 2000
        )

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: emptyHistory,
            userBookmarks: [],
            userRatings: [],
            userLocation: nil
        )

        XCTAssertEqual(score, 10)
    }

    // MARK: - Test: Combined scoring

    func testCombinedScoring() {
        let venueId = UUID()
        let dealId = UUID()
        let deal = makeDeal(
            id: dealId,
            category: "drink",
            venueId: venueId,
            expiresAt: Date().addingTimeInterval(1800), // 30 min (urgency)
            startsAt: Date().addingTimeInterval(-1800), // 30 min ago (new)
            distanceFromUser: 400 // close (proximity)
        )

        let history = RecommendationEngine.UserHistory(
            redeemedDealIds: [UUID()],
            redeemedCategories: ["drink"], // category match
            redeemedVenueIds: [venueId],   // venue match
            redeemedDealTitles: [:],
            redeemedVenueNames: [:]
        )

        let ratings = [
            RecommendationEngine.UserRating(dealId: dealId, rating: 4.8)
        ]

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: history,
            userBookmarks: [],
            userRatings: ratings,
            userLocation: nil
        )

        // 25 (category) + 20 (venue) + 15 (rating) + 20 (urgency) + 10 (proximity) + 10 (new) = 100
        XCTAssertEqual(score, 100)
    }

    // MARK: - Test: Score capped at 100

    func testScoreCappedAt100() {
        // Same as combined — all factors hit, should be exactly 100
        let venueId = UUID()
        let dealId = UUID()
        let deal = makeDeal(
            id: dealId,
            category: "drink",
            venueId: venueId,
            expiresAt: Date().addingTimeInterval(1800),
            startsAt: Date().addingTimeInterval(-1800),
            distanceFromUser: 400
        )

        let history = RecommendationEngine.UserHistory(
            redeemedDealIds: [UUID()],
            redeemedCategories: ["drink"],
            redeemedVenueIds: [venueId],
            redeemedDealTitles: [:],
            redeemedVenueNames: [:]
        )

        let ratings = [
            RecommendationEngine.UserRating(dealId: dealId, rating: 5.0)
        ]

        let score = RecommendationEngine.score(
            deal: deal,
            userHistory: history,
            userBookmarks: [],
            userRatings: ratings,
            userLocation: nil
        )

        XCTAssertLessThanOrEqual(score, 100)
    }

    // MARK: - Test: recommend() returns sorted results

    func testRecommendReturnsSorted() {
        let deal1 = makeDeal(
            category: "food",
            expiresAt: Date().addingTimeInterval(86400),
            startsAt: Date().addingTimeInterval(-86400 * 2),
            distanceFromUser: 2000
        )
        let deal2 = makeDeal(
            category: "drink",
            expiresAt: Date().addingTimeInterval(1800), // urgency
            startsAt: Date().addingTimeInterval(-1800), // new
            distanceFromUser: 400 // close
        )

        let history = RecommendationEngine.UserHistory(
            redeemedDealIds: [],
            redeemedCategories: ["drink"],
            redeemedVenueIds: [],
            redeemedDealTitles: [:],
            redeemedVenueNames: [:]
        )

        let results = RecommendationEngine.recommend(
            deals: [deal1, deal2],
            userHistory: history,
            userBookmarks: [],
            userRatings: [],
            userLocation: nil
        )

        XCTAssertGreaterThanOrEqual(results.count, 1)
        // deal2 should score higher (category + urgency + proximity + new = 65 vs 0)
        XCTAssertEqual(results.first?.deal.id, deal2.id)
    }
}
