import SwiftUI
import CoreLocation
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Recommendations")

@MainActor
class RecommendationViewModel: ObservableObject {
    @Published var recommendations: [RecommendationEngine.ScoredDeal] = []
    @Published var isLoading = false
    @Published var hasHistory = false

    private let bookmarkService = BookmarkService.shared
    private let locationService = LocationService()
    private let supabaseClient = SupabaseClientService.shared.client

    // MARK: - Load Recommendations

    func loadRecommendations(deals: [Deal]) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let history = await fetchUserHistory()
            let ratings = await fetchUserRatings()
            let bookmarks = bookmarkService.savedDealIds

            hasHistory = !history.redeemedDealIds.isEmpty

            let results = RecommendationEngine.recommend(
                deals: deals,
                userHistory: history,
                userBookmarks: bookmarks,
                userRatings: ratings,
                userLocation: locationService.currentLocation?.coordinate,
                limit: 8
            )

            withAnimation(.easeInOut(duration: 0.3)) {
                recommendations = results
            }

            logger.info("Generated \(results.count) recommendations")
        }
    }

    // MARK: - Supabase Fetches

    private func fetchUserHistory() async -> RecommendationEngine.UserHistory {
        // Fetch redemption history from Supabase
        // Falls back to empty if unavailable
        do {
            struct RedemptionRow: Decodable {
                let dealId: UUID
                let venueId: UUID?
                let dealTitle: String?
                let dealCategory: String?
                let venueName: String?

                enum CodingKeys: String, CodingKey {
                    case dealId = "deal_id"
                    case venueId = "venue_id"
                    case dealTitle = "deal_title"
                    case dealCategory = "deal_category"
                    case venueName = "venue_name"
                }
            }

            let rows: [RedemptionRow] = try await supabaseClient
                .from("redemptions")
                .select("deal_id, venue_id, deal_title, deal_category, venue_name")
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value

            return RecommendationEngine.UserHistory(
                redeemedDealIds: rows.map(\.dealId),
                redeemedCategories: rows.compactMap(\.dealCategory),
                redeemedVenueIds: rows.compactMap(\.venueId),
                redeemedDealTitles: Dictionary(uniqueKeysWithValues: rows.compactMap { row in
                    row.dealTitle.map { (row.dealId, $0) }
                }),
                redeemedVenueNames: Dictionary(uniqueKeysWithValues: rows.compactMap { row in
                    guard let venueId = row.venueId, let name = row.venueName else { return nil }
                    return (venueId, name)
                })
            )
        } catch {
            logger.error("Failed to fetch user history: \(error)")
            return RecommendationEngine.UserHistory(
                redeemedDealIds: [],
                redeemedCategories: [],
                redeemedVenueIds: [],
                redeemedDealTitles: [:],
                redeemedVenueNames: [:]
            )
        }
    }

    private func fetchUserRatings() async -> [RecommendationEngine.UserRating] {
        do {
            struct RatingRow: Decodable {
                let dealId: UUID
                let rating: Double
                enum CodingKeys: String, CodingKey {
                    case dealId = "deal_id"
                    case rating
                }
            }

            let rows: [RatingRow] = try await supabaseClient
                .from("ratings")
                .select("deal_id, rating")
                .limit(100)
                .execute()
                .value

            return rows.map { RecommendationEngine.UserRating(dealId: $0.dealId, rating: $0.rating) }
        } catch {
            logger.error("Failed to fetch user ratings: \(error)")
            return []
        }
    }
}
