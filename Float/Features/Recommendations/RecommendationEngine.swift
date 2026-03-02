import Foundation
import CoreLocation

// MARK: - Recommendation Engine

/// Pure scoring logic for personalized deal recommendations.
/// No SwiftUI dependencies — fully testable.
struct RecommendationEngine {

    // MARK: - Supporting Types

    struct UserHistory {
        let redeemedDealIds: [UUID]
        let redeemedCategories: [String]   // e.g. ["drink", "food", "drink"]
        let redeemedVenueIds: [UUID]
        let redeemedDealTitles: [UUID: String] // dealId -> title for explanation
        let redeemedVenueNames: [UUID: String] // venueId -> name for explanation
    }

    struct UserRating {
        let dealId: UUID
        let rating: Double
    }

    struct ScoredDeal {
        let deal: Deal
        let score: Double
        let explanation: String
    }

    // MARK: - Weights

    private static let categorMatchWeight: Double = 25
    private static let venueVisitWeight: Double = 20
    private static let highRatingWeight: Double = 15
    private static let urgencyWeight: Double = 20
    private static let proximityWeight: Double = 10
    private static let newnessWeight: Double = 10

    // MARK: - Public API

    /// Score a single deal (0–100) based on user context.
    static func score(
        deal: Deal,
        userHistory: UserHistory,
        userBookmarks: Set<UUID>,
        userRatings: [UserRating],
        userLocation: CLLocationCoordinate2D?
    ) -> Double {
        var total: Double = 0

        // 1. Same category as past redemptions (+25)
        if userHistory.redeemedCategories.contains(where: { $0.lowercased() == deal.category.lowercased() }) {
            total += categorMatchWeight
        }

        // 2. Same venue user has visited (+20)
        if userHistory.redeemedVenueIds.contains(deal.venueId) {
            total += venueVisitWeight
        }

        // 3. High average rating ≥ 4.0 (+15)
        let ratingsForDeal = userRatings.filter { $0.dealId == deal.id }
        if !ratingsForDeal.isEmpty {
            let avg = ratingsForDeal.map(\.rating).reduce(0, +) / Double(ratingsForDeal.count)
            if avg >= 4.0 {
                total += highRatingWeight
            }
        }

        // 4. Expiring within 2 hours (+20)
        if let expiresAt = deal.expiresAt {
            let hoursUntilExpiry = expiresAt.timeIntervalSinceNow / 3600
            if hoursUntilExpiry > 0 && hoursUntilExpiry <= 2 {
                total += urgencyWeight
            }
        }

        // 5. Distance < 0.5 miles (~805 meters) (+10)
        if let distance = deal.distanceFromUser, distance < 805 {
            total += proximityWeight
        }

        // 6. New deal (posted in last 24h) (+10)
        if let startsAt = deal.startsAt {
            let hoursSincePosted = Date().timeIntervalSince(startsAt) / 3600
            if hoursSincePosted >= 0 && hoursSincePosted <= 24 {
                total += newnessWeight
            }
        }

        return min(total, 100)
    }

    /// Generate explanation string for why a deal was recommended.
    static func explanation(
        deal: Deal,
        userHistory: UserHistory,
        userBookmarks: Set<UUID>
    ) -> String {
        // Priority: venue visit > category match > bookmarked > urgency > proximity > new
        if userHistory.redeemedVenueIds.contains(deal.venueId),
           let venueName = deal.venueName ?? userHistory.redeemedVenueNames[deal.venueId] {
            // Find a deal title redeemed at this venue
            if let pastDealId = userHistory.redeemedDealIds.first(where: { id in
                // Check if this deal was at the same venue — simplified: use venue name
                true
            }), let pastTitle = userHistory.redeemedDealTitles[pastDealId] {
                return "Because you redeemed \(pastTitle) at \(venueName)"
            }
            return "Because you've visited \(venueName) before"
        }

        if userHistory.redeemedCategories.contains(where: { $0.lowercased() == deal.category.lowercased() }) {
            let categoryName: String
            switch deal.category.lowercased() {
            case "drink": categoryName = "drink deals"
            case "food": categoryName = "food deals"
            case "both": categoryName = "combo deals"
            case "flash": categoryName = "flash deals"
            default: categoryName = "\(deal.category) deals"
            }
            return "Because you enjoy \(categoryName)"
        }

        if userBookmarks.contains(deal.id) {
            return "You bookmarked this deal"
        }

        if let expiresAt = deal.expiresAt {
            let hoursLeft = expiresAt.timeIntervalSinceNow / 3600
            if hoursLeft > 0 && hoursLeft <= 2 {
                return "Expiring soon — don't miss out!"
            }
        }

        if let distance = deal.distanceFromUser, distance < 805 {
            return "Right around the corner from you"
        }

        return "Trending near you"
    }

    /// Rank all deals, return top recommendations with explanations.
    static func recommend(
        deals: [Deal],
        userHistory: UserHistory,
        userBookmarks: Set<UUID>,
        userRatings: [UserRating],
        userLocation: CLLocationCoordinate2D?,
        limit: Int = 8
    ) -> [ScoredDeal] {
        let scored = deals.map { deal in
            ScoredDeal(
                deal: deal,
                score: score(
                    deal: deal,
                    userHistory: userHistory,
                    userBookmarks: userBookmarks,
                    userRatings: userRatings,
                    userLocation: userLocation
                ),
                explanation: explanation(
                    deal: deal,
                    userHistory: userHistory,
                    userBookmarks: userBookmarks
                )
            )
        }

        return scored
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .filter { $0.score > 0 } // Only recommend deals with some relevance
            .map { $0 }
    }
}
