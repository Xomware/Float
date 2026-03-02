// NotificationService.swift
// Float

import UserNotifications
import UIKit
import OSLog
import Supabase

private let logger = Logger(subsystem: "com.xomware.float", category: "Notifications")

// MARK: - NotificationService

/// Central notification service for Float.
/// Handles:
///  - Requesting UNUserNotificationCenter permission
///  - Registering APNs device tokens with Supabase
///  - Scheduling local notifications (expiry alerts)
///  - Handling foreground notification presentation
@MainActor
final class NotificationService: NSObject, ObservableObject {

    // MARK: - Singleton
    static let shared = NotificationService()

    // MARK: - Published State
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isRegisteredForRemoteNotifications = false
    @Published var pendingNotifications: [UNNotificationRequest] = []

    // MARK: - Private
    private let center = UNUserNotificationCenter.current()
    private let supabase = SupabaseClientService.shared.client

    // MARK: - Init
    override private init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Permission & Registration

    /// Requests notification authorization, then registers for remote (APNs) notifications.
    func requestPermissionAndRegister() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
            logger.info("Notification permission granted: \(granted)")
            await checkStatus()

            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } catch {
            logger.error("Notification permission error: \(error)")
        }
    }

    /// Checks and updates the current authorization status.
    func checkStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        logger.debug("Notification status: \(settings.authorizationStatus.rawValue)")
    }

    // MARK: - APNs Token Registration

    /// Called by AppDelegate when a device token is received.
    /// Stores the token on the Supabase `push_tokens` table.
    func registerDeviceToken(_ tokenData: Data, userId: String) async {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        logger.info("Registering APNs token for user \(userId): \(token.prefix(8))...")

        isRegisteredForRemoteNotifications = true

        do {
            // Upsert into push_tokens table (on conflict: update token + mark active)
            let record = PushTokenUpsert(
                userId: userId,
                deviceToken: token,
                platform: "ios",
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            )
            try await supabase
                .from("push_tokens")
                .upsert(record, onConflict: "user_id, device_token")
                .execute()

            logger.info("APNs token registered successfully")
        } catch {
            logger.error("Failed to register APNs token: \(error)")
            // Persist locally for retry on next launch
            UserDefaults.standard.set(token, forKey: "float_pending_apns_token")
            UserDefaults.standard.set(userId, forKey: "float_pending_apns_user_id")
        }
    }

    /// Retries registering a pending token (e.g., when network was unavailable at launch).
    func retryPendingTokenRegistration() async {
        guard
            let token = UserDefaults.standard.string(forKey: "float_pending_apns_token"),
            let userId = UserDefaults.standard.string(forKey: "float_pending_apns_user_id")
        else { return }

        logger.info("Retrying pending APNs token registration")
        let tokenData = Data(hexString: token)
        await registerDeviceToken(tokenData, userId: userId)

        // Clear pending on success
        UserDefaults.standard.removeObject(forKey: "float_pending_apns_token")
        UserDefaults.standard.removeObject(forKey: "float_pending_apns_user_id")
    }

    /// Deactivates all push tokens for the given user (on sign-out).
    func deactivateTokens(for userId: String) async {
        do {
            try await supabase
                .from("push_tokens")
                .update(["is_active": false])
                .eq("user_id", value: userId)
                .execute()
            isRegisteredForRemoteNotifications = false
            logger.info("Deactivated push tokens for user \(userId)")
        } catch {
            logger.error("Failed to deactivate push tokens: \(error)")
        }
    }

    // MARK: - Local Notification Scheduling

    /// Schedules a local alert 30 minutes before a deal expires.
    func scheduleExpiryAlert(dealId: String, dealTitle: String, expiresAt: Date) async {
        let triggerDate = expiresAt.addingTimeInterval(-1800) // 30 min before
        guard triggerDate > Date() else {
            logger.debug("Skipping expiry alert — trigger date already passed for: \(dealTitle)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Deal Expiring Soon! ⏰"
        content.body = "\(dealTitle) expires in 30 minutes. Redeem it now!"
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "notification_type": NotificationType.dealExpiringSoon.rawValue,
            "deal_id": dealId
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "deal-expiry-\(dealId)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.info("Scheduled expiry alert for deal: \(dealId) at \(triggerDate)")
        } catch {
            logger.error("Failed to schedule expiry alert: \(error)")
        }
    }

    /// Removes a previously scheduled expiry alert (e.g., if deal was extended or deleted).
    func cancelExpiryAlert(for dealId: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["deal-expiry-\(dealId)"])
        logger.info("Cancelled expiry alert for deal: \(dealId)")
    }

    /// Delivers an immediate local notification for a nearby venue deal (from geofence trigger).
    func scheduleNearbyDealAlert(venueId: String, venueName: String, dealId: String, dealTitle: String) async {
        let content = UNMutableNotificationContent()
        content.title = "🍹 Deal Nearby at \(venueName)"
        content.body = dealTitle
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "notification_type": NotificationType.geofenceNearbyDeal.rawValue,
            "deal_id": dealId,
            "venue_id": venueId
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "nearby-\(venueId)-\(dealId)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.info("Scheduled nearby deal alert for venue: \(venueId)")
        } catch {
            logger.error("Failed to schedule nearby deal alert: \(error)")
        }
    }

    /// Delivers an immediate local notification for a favorited venue's new deal.
    func scheduleFavoriteVenueAlert(venueId: String, venueName: String, dealId: String, dealTitle: String) async {
        let content = UNMutableNotificationContent()
        content.title = "New Deal from \(venueName)! 🎉"
        content.body = dealTitle
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "notification_type": NotificationType.favoritedVenueNewDeal.rawValue,
            "deal_id": dealId,
            "venue_id": venueId
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "fav-venue-\(venueId)-\(dealId)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.info("Scheduled favorite venue alert for venue: \(venueId)")
        } catch {
            logger.error("Failed to schedule favorite venue alert: \(error)")
        }
    }

    // MARK: - Badge Management

    /// Resets the app badge count to zero.
    func clearBadge() async {
        do {
            try await center.setBadgeCount(0)
        } catch {
            logger.error("Failed to clear badge: \(error)")
        }
    }

    // MARK: - Pending Notifications

    /// Refreshes the list of pending notification requests.
    func refreshPendingNotifications() async {
        pendingNotifications = await center.pendingNotificationRequests()
    }

    // MARK: - Notification Log

    /// Logs a sent notification to Supabase for in-app notification history.
    func logNotification(
        userId: String,
        type: NotificationType,
        title: String,
        body: String,
        dealId: String? = nil,
        venueId: String? = nil
    ) async {
        do {
            let entry = NotificationLogInsert(
                userId: userId,
                notificationType: type.rawValue,
                title: title,
                body: body,
                dealId: dealId,
                venueId: venueId
            )
            try await supabase
                .from("notification_log")
                .insert(entry)
                .execute()
        } catch {
            logger.error("Failed to log notification: \(error)")
        }
    }

    /// Fetches notification history for the current user.
    func fetchNotificationHistory(userId: String, limit: Int = 50) async -> [NotificationLogEntry] {
        do {
            let entries: [NotificationLogEntry] = try await supabase
                .from("notification_log")
                .select()
                .eq("user_id", value: userId)
                .order("sent_at", ascending: false)
                .limit(limit)
                .execute()
                .value
            return entries
        } catch {
            logger.error("Failed to fetch notification log: \(error)")
            return []
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {

    /// Show notification banners even when the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap — navigate to the relevant deal or venue.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        Task { @MainActor in
            await self.clearBadge()

            if let dealId = userInfo["deal_id"] as? String {
                logger.info("Notification tapped → navigate to deal: \(dealId)")
                NotificationCenter.default.post(
                    name: .floatNavigateToDeal,
                    object: nil,
                    userInfo: ["deal_id": dealId]
                )
            } else if let venueId = userInfo["venue_id"] as? String {
                logger.info("Notification tapped → navigate to venue: \(venueId)")
                NotificationCenter.default.post(
                    name: .floatNavigateToVenue,
                    object: nil,
                    userInfo: ["venue_id": venueId]
                )
            }
        }

        completionHandler()
    }
}

// MARK: - Notification Name Constants

extension Notification.Name {
    static let floatNavigateToDeal = Notification.Name("com.xomware.float.navigateToDeal")
    static let floatNavigateToVenue = Notification.Name("com.xomware.float.navigateToVenue")
}

// MARK: - Private Supabase Encodable Structs

private struct PushTokenUpsert: Encodable {
    let userId: String
    let deviceToken: String
    let platform: String
    let appVersion: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceToken = "device_token"
        case platform
        case appVersion = "app_version"
        case isActive = "is_active"
    }

    init(userId: String, deviceToken: String, platform: String, appVersion: String) {
        self.userId = userId
        self.deviceToken = deviceToken
        self.platform = platform
        self.appVersion = appVersion
        self.isActive = true
    }
}

private struct NotificationLogInsert: Encodable {
    let userId: String
    let notificationType: String
    let title: String
    let body: String
    let dealId: String?
    let venueId: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case notificationType = "notification_type"
        case title
        case body
        case dealId = "deal_id"
        case venueId = "venue_id"
    }
}

// MARK: - Data Hex Extension

extension Data {
    init(hexString: String) {
        self = stride(from: 0, to: hexString.count, by: 2).compactMap {
            let start = hexString.index(hexString.startIndex, offsetBy: $0)
            let end = hexString.index(start, offsetBy: 2, limitedBy: hexString.endIndex) ?? hexString.endIndex
            return UInt8(hexString[start..<end], radix: 16)
        }.reduce(into: Data()) { $0.append($1) }
    }
}
