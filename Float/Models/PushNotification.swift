// PushNotification.swift
// Float

import Foundation

// MARK: - Push Notification Payload Models

/// APNs alert payload structure
struct APNsAlert: Codable {
    let title: String
    let body: String
    let subtitle: String?

    init(title: String, body: String, subtitle: String? = nil) {
        self.title = title
        self.body = body
        self.subtitle = subtitle
    }
}

/// APNs aps dictionary
struct APNsPayload: Codable {
    let alert: APNsAlert
    let sound: String
    let badge: Int?
    let contentAvailable: Int?
    let mutableContent: Int?

    enum CodingKeys: String, CodingKey {
        case alert
        case sound
        case badge
        case contentAvailable = "content-available"
        case mutableContent = "mutable-content"
    }

    init(
        alert: APNsAlert,
        sound: String = "default",
        badge: Int? = nil,
        contentAvailable: Int? = nil,
        mutableContent: Int? = nil
    ) {
        self.alert = alert
        self.sound = sound
        self.badge = badge
        self.contentAvailable = contentAvailable
        self.mutableContent = mutableContent
    }
}

/// Float custom push payload for deep linking
struct FloatPushPayload: Codable {
    let aps: APNsPayload
    let notificationType: NotificationType
    let dealId: String?
    let venueId: String?

    enum CodingKeys: String, CodingKey {
        case aps
        case notificationType = "notification_type"
        case dealId = "deal_id"
        case venueId = "venue_id"
    }
}

/// Notification types for Float
enum NotificationType: String, Codable {
    case favoritedVenueNewDeal = "favorited_venue_new_deal"
    case geofenceNearbyDeal = "geofence_nearby_deal"
    case dealExpiringSoon = "deal_expiring_soon"
    case systemAnnouncement = "system_announcement"
}

// MARK: - Push Token Registration

/// Request body for registering a device token with the backend
struct PushTokenRegistrationRequest: Encodable {
    let userId: String
    let deviceToken: String
    let platform: String
    let appVersion: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceToken = "device_token"
        case platform
        case appVersion = "app_version"
    }

    init(userId: String, deviceToken: String) {
        self.userId = userId
        self.deviceToken = deviceToken
        self.platform = "ios"
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Notification Log Entry

/// A record of a sent notification (mirrors notification_log table)
struct NotificationLogEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let notificationType: String
    let title: String
    let body: String
    let dealId: UUID?
    let venueId: UUID?
    let sentAt: Date
    let isRead: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case notificationType = "notification_type"
        case title
        case body
        case dealId = "deal_id"
        case venueId = "venue_id"
        case sentAt = "sent_at"
        case isRead = "is_read"
    }
}

// MARK: - Push Token Record

/// Mirrors the push_tokens table in Supabase
struct PushTokenRecord: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let deviceToken: String
    let platform: String
    let appVersion: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case deviceToken = "device_token"
        case platform
        case appVersion = "app_version"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
