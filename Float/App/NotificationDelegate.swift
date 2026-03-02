// NotificationDelegate.swift
// Float

import UserNotifications
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "NotificationDelegate")

/// Handles local notification responses (deal expiry deep links).
/// Set as UNUserNotificationCenter delegate at app launch.
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    /// Called when user taps a notification or its action button.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let dealIdString = userInfo["dealId"] as? String,
              let dealId = UUID(uuidString: dealIdString) else {
            completionHandler()
            return
        }

        if response.actionIdentifier == NotificationScheduler.viewDealActionId ||
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            logger.info("Deal expiry notification tapped — deal: \(dealId)")
            // Post notification for FloatApp to handle navigation
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .floatDealExpiryNotificationTapped,
                    object: nil,
                    userInfo: ["dealId": dealId]
                )
            }
        }

        completionHandler()
    }

    /// Show notifications even when app is in foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

// MARK: - Notification Name

extension Foundation.Notification.Name {
    static let floatDealExpiryNotificationTapped = Foundation.Notification.Name("floatDealExpiryNotificationTapped")
}
