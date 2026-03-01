import Foundation

// MARK: - Friend Connection

struct FriendConnection: Codable, Identifiable {
    let id: UUID
    let requesterId: UUID
    let addresseeId: UUID
    let status: FriendStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case requesterId = "requester_id"
        case addresseeId = "addressee_id"
        case status
        case createdAt = "created_at"
    }
}

enum FriendStatus: String, Codable {
    case pending
    case accepted
    case declined
}

// MARK: - Friend Activity Item

struct FriendActivityItem: Identifiable {
    let id: UUID
    let userId: UUID
    let username: String
    let displayName: String
    let avatarUrl: String?
    let dealId: UUID
    let dealTitle: String
    let venueName: String
    let redeemedAt: Date
    let redemptionId: UUID
    var isLiked: Bool
    var likeCount: Int
}

// MARK: - Activity Like

struct ActivityLike: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let redemptionId: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case redemptionId = "redemption_id"
        case createdAt = "created_at"
    }
}

// MARK: - Friend Activity Response (from Supabase join query)

struct FriendActivityResponse: Codable {
    let id: UUID
    let userId: UUID
    let dealId: UUID
    let createdAt: Date
    let userProfile: ActivityUserProfile
    let deal: ActivityDeal
    let venue: ActivityVenue

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case dealId = "deal_id"
        case createdAt = "created_at"
        case userProfile = "user_profiles"
        case deal = "deals"
        case venue = "venues"
    }
}

struct ActivityUserProfile: Codable {
    let id: UUID
    let username: String?
    let displayName: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
    }
}

struct ActivityDeal: Codable {
    let id: UUID
    let title: String
    let venueId: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case venueId = "venue_id"
    }
}

struct ActivityVenue: Codable {
    let id: UUID
    let name: String
}
