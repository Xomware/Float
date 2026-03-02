import Foundation
import Supabase
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Rating")

/// Codable model for deal_ratings table rows
struct DealRating: Codable, Identifiable {
    let id: UUID?
    let userId: UUID
    let dealId: UUID
    let rating: Int
    let review: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case dealId = "deal_id"
        case rating
        case review
        case createdAt = "created_at"
    }
}

/// Codable model for deal_rating_summary view
struct DealRatingSummary: Codable {
    let dealId: UUID
    let avgRating: Double
    let reviewCount: Int

    enum CodingKeys: String, CodingKey {
        case dealId = "deal_id"
        case avgRating = "avg_rating"
        case reviewCount = "review_count"
    }
}

/// Handles Supabase interactions for deal ratings
final class RatingService {
    static let shared = RatingService()
    private let client = SupabaseClientService.shared.client

    private init() {}

    /// Upsert a rating (insert or update if user already rated this deal)
    func submitRating(dealId: UUID, userId: UUID, rating: Int, review: String?) async throws {
        let payload = DealRating(
            id: nil,
            userId: userId,
            dealId: dealId,
            rating: rating,
            review: review,
            createdAt: nil
        )

        try await client.from("deal_ratings")
            .upsert(payload, onConflict: "user_id,deal_id")
            .execute()

        logger.info("Rating submitted: deal=\(dealId), rating=\(rating)")
    }

    /// Fetch average rating and review count for a deal
    func fetchAverageRating(dealId: UUID) async throws -> (average: Double, count: Int) {
        let response: [DealRatingSummary] = try await client.from("deal_rating_summary")
            .select()
            .eq("deal_id", value: dealId.uuidString)
            .execute()
            .value

        guard let summary = response.first else {
            return (0.0, 0)
        }

        return (summary.avgRating, summary.reviewCount)
    }

    /// Fetch user's existing rating for a deal (if any)
    func fetchUserRating(dealId: UUID, userId: UUID) async throws -> DealRating? {
        let response: [DealRating] = try await client.from("deal_ratings")
            .select()
            .eq("deal_id", value: dealId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        return response.first
    }
}
