import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var username: String?
    var displayName: String?
    var avatarUrl: String?
    var bio: String?
    var locationCity: String?
    var locationState: String?
    var totalRedemptions: Int
    var totalSavings: Double
    var notificationPrefs: NotificationPrefs
    var isMerchant: Bool
    var activityVisibility: ActivityVisibility
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case bio
        case locationCity = "location_city"
        case locationState = "location_state"
        case totalRedemptions = "total_redemptions"
        case totalSavings = "total_savings"
        case notificationPrefs = "notification_prefs"
        case isMerchant = "is_merchant"
        case activityVisibility = "activity_visibility"
        case createdAt = "created_at"
    }
}

// MARK: - Activity Visibility

enum ActivityVisibility: String, Codable, CaseIterable {
    case `public` = "public"
    case friends = "friends"
    case `private` = "private"

    var displayName: String {
        switch self {
        case .public: return "Everyone"
        case .friends: return "Friends Only"
        case .private: return "Only Me"
        }
    }

    var icon: String {
        switch self {
        case .public: return "globe"
        case .friends: return "person.2.fill"
        case .private: return "lock.fill"
        }
    }
}

struct NotificationPrefs: Codable {
    var dealsNearby: Bool
    var expiringSoon: Bool
    var newVenues: Bool
    var weeklyRoundup: Bool
    
    enum CodingKeys: String, CodingKey {
        case dealsNearby = "deals_nearby"
        case expiringSoon = "expiring_soon"
        case newVenues = "new_venues"
        case weeklyRoundup = "weekly_roundup"
    }
    
    static let `default` = NotificationPrefs(dealsNearby: true, expiringSoon: true, newVenues: false, weeklyRoundup: true)
}
