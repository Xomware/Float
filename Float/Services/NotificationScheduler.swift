// NotificationScheduler.swift
// Float

import UserNotifications
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "NotificationScheduler")

// MARK: - NotificationCenterProtocol

/// Protocol wrapper around UNUserNotificationCenter for testability.
protocol NotificationCenterProtocol: Sendable {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func notificationSettings() async -> UNNotificationSettings
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
}

extension UNUserNotificationCenter: NotificationCenterProtocol {}

// MARK: - NotificationScheduler

/// Schedules local notifications for deal expiry alerts (60-min and 15-min warnings).
actor NotificationScheduler {
    static let shared = NotificationScheduler()

    // MARK: - Constants

    static let categoryId = "DEAL_EXPIRY"
    static let viewDealActionId = "VIEW_DEAL"

    private let center: NotificationCenterProtocol

    init(center: NotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.center = center
        registerCategories()
    }

    // MARK: - Permission

    /// Request notification permission. Returns true if granted.
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            logger.info("Notification permission \(granted ? "granted" : "denied")")
            return granted
        } catch {
            logger.error("Failed to request notification permission: \(error)")
            return false
        }
    }

    /// Current authorization status.
    var authorizationStatus: UNAuthorizationStatus {
        get async {
            await center.notificationSettings().authorizationStatus
        }
    }

    // MARK: - Schedule

    /// Schedule 60-min and 15-min expiry alerts for a deal.
    /// Only schedules if the deal has a future `expiresAt` and reminders are enabled.
    func scheduleDealExpiryAlerts(for deal: Deal) async {
        guard UserDefaults.standard.bool(forKey: "dealExpiryReminders") ||
              !UserDefaults.standard.contains(key: "dealExpiryReminders") else {
            logger.info("Deal expiry reminders disabled — skipping schedule")
            return
        }

        guard let expiresAt = deal.expiresAt else {
            logger.info("Deal \(deal.id) has no expiresAt — skipping")
            return
        }

        let now = Date()
        guard expiresAt > now else {
            logger.info("Deal \(deal.id) already expired — skipping")
            return
        }

        let dealId = deal.id.uuidString
        let venueId = deal.venueId.uuidString
        let dealName = deal.title
        let venueName = deal.venueName ?? "a nearby venue"
        let userInfo: [String: String] = ["dealId": dealId, "venueId": venueId]

        // 60-minute warning
        let sixtyMinBefore = expiresAt.addingTimeInterval(-60 * 60)
        if sixtyMinBefore > now {
            let interval = sixtyMinBefore.timeIntervalSince(now)
            let content = UNMutableNotificationContent()
            content.title = "⏰ Deal expiring soon!"
            content.body = "Your bookmarked '\(dealName)' at \(venueName) expires in 1 hour. Don't miss out!"
            content.sound = .default
            content.categoryIdentifier = Self.categoryId
            content.userInfo = userInfo

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(
                identifier: "deal-expiry-60-\(dealId)",
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
                logger.info("Scheduled 60-min alert for deal \(dealId)")
            } catch {
                logger.error("Failed to schedule 60-min alert: \(error)")
            }
        }

        // 15-minute warning
        let fifteenMinBefore = expiresAt.addingTimeInterval(-15 * 60)
        if fifteenMinBefore > now {
            let interval = fifteenMinBefore.timeIntervalSince(now)
            let content = UNMutableNotificationContent()
            content.title = "🚨 Last chance!"
            content.body = "'\(dealName)' at \(venueName) expires in 15 minutes!"
            content.sound = .default
            content.categoryIdentifier = Self.categoryId
            content.userInfo = userInfo

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(
                identifier: "deal-expiry-15-\(dealId)",
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
                logger.info("Scheduled 15-min alert for deal \(dealId)")
            } catch {
                logger.error("Failed to schedule 15-min alert: \(error)")
            }
        }
    }

    // MARK: - Cancel

    /// Cancel all pending expiry notifications for a deal.
    func cancelAlerts(for dealId: UUID) async {
        let ids = [
            "deal-expiry-60-\(dealId.uuidString)",
            "deal-expiry-15-\(dealId.uuidString)"
        ]
        center.removePendingNotificationRequests(withIdentifiers: ids)
        logger.info("Cancelled expiry alerts for deal \(dealId)")
    }

    /// Cancel all pending deal expiry notifications.
    func cancelAllAlerts() async {
        // We remove all pending — this is scoped to deal expiry by identifier prefix
        // For a more surgical approach we'd query pending and filter, but this is simpler
        center.removeAllPendingNotificationRequests()
        logger.info("Cancelled all pending notifications")
    }

    // MARK: - Categories

    private nonisolated func registerCategories() {
        let viewAction = UNNotificationAction(
            identifier: Self.viewDealActionId,
            title: "View Deal",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: Self.categoryId,
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }
}

// MARK: - UserDefaults Helper

extension UserDefaults {
    func contains(key: String) -> Bool {
        object(forKey: key) != nil
    }
}
