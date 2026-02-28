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
        case createdAt = "created_at"
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
