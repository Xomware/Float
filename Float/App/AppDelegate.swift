// AppDelegate.swift
// Float

import UIKit
import UserNotifications
import BackgroundTasks
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "AppDelegate")

// Background task identifiers
enum BackgroundTaskID {
    static let geofenceRefresh = "com.xomware.float.geofence-refresh"
    static let notificationSync = "com.xomware.float.notification-sync"
}

class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Application Launch

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set the notification delegate on the shared service
        UNUserNotificationCenter.current().delegate = NotificationService.shared

        // Register background tasks
        registerBackgroundTasks()

        logger.info("Float launched")
        return true
    }

    // MARK: - APNs Token Registration

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenHex = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        logger.info("APNs token received: \(tokenHex.prefix(8))...")

        // Get the current authenticated user ID from AuthService
        Task { @MainActor in
            // We post a notification so FloatApp / AuthService can pick this up
            // while holding the userId from their @StateObject
            NotificationCenter.default.post(
                name: .floatAPNsTokenReceived,
                object: nil,
                userInfo: ["device_token_data": deviceToken]
            )
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        logger.error("Failed to register for remote notifications: \(error)")
    }

    // MARK: - Background Fetch / BGTask

    func applicationDidBecomeActive(_ application: UIApplication) {
        Task { @MainActor in
            await NotificationService.shared.clearBadge()
            await NotificationService.shared.checkStatus()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleGeofenceRefresh()
        scheduleNotificationSync()
    }

    // MARK: - Background Task Registration

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskID.geofenceRefresh,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleGeofenceRefresh(task: refreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskID.notificationSync,
            using: nil
        ) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            self.handleNotificationSync(task: processingTask)
        }

        logger.info("Background tasks registered")
    }

    private func scheduleGeofenceRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: BackgroundTaskID.geofenceRefresh)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60) // 30 min

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Geofence refresh background task scheduled")
        } catch {
            logger.error("Failed to schedule geofence refresh: \(error)")
        }
    }

    private func scheduleNotificationSync() {
        let request = BGProcessingTaskRequest(identifier: BackgroundTaskID.notificationSync)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        request.requiresNetworkConnectivity = true

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Notification sync background task scheduled")
        } catch {
            logger.error("Failed to schedule notification sync: \(error)")
        }
    }

    // MARK: - Background Task Handlers

    private func handleGeofenceRefresh(task: BGAppRefreshTask) {
        // Re-schedule for next run before doing work
        scheduleGeofenceRefresh()

        let geofenceTask = Task {
            // Post so FloatApp (which has the userId) can trigger refresh
            await MainActor.run {
                NotificationCenter.default.post(name: .floatGeofenceRefreshNeeded, object: nil)
            }
        }

        task.expirationHandler = {
            geofenceTask.cancel()
            logger.warning("Geofence refresh task expired")
        }

        Task {
            await geofenceTask.value
            task.setTaskCompleted(success: true)
        }
    }

    private func handleNotificationSync(task: BGProcessingTask) {
        scheduleNotificationSync()

        let syncTask = Task {
            await MainActor.run {
                NotificationCenter.default.post(name: .floatNotificationSyncNeeded, object: nil)
            }
        }

        task.expirationHandler = {
            syncTask.cancel()
            logger.warning("Notification sync task expired")
        }

        Task {
            await syncTask.value
            task.setTaskCompleted(success: true)
        }
    }

    // MARK: - Universal Links / Deep Links

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return false }

        logger.info("Universal link received: \(url)")
        return handleDeepLink(url: url)
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        logger.info("Deep link received: \(url)")
        return handleDeepLink(url: url)
    }

    private func handleDeepLink(url: URL) -> Bool {
        guard url.scheme == "com.xomware.float" || url.host == "float.xomware.com" else { return false }

        let path = url.pathComponents
        if path.count >= 3, path[1] == "deals" {
            NotificationCenter.default.post(
                name: .floatNavigateToDeal,
                object: nil,
                userInfo: ["deal_id": path[2]]
            )
            return true
        }
        if path.count >= 3, path[1] == "venues" {
            NotificationCenter.default.post(
                name: .floatNavigateToVenue,
                object: nil,
                userInfo: ["venue_id": path[2]]
            )
            return true
        }
        return false
    }
}

// MARK: - Additional Notification Names

extension Notification.Name {
    static let floatAPNsTokenReceived = Notification.Name("com.xomware.float.apnsTokenReceived")
    static let floatGeofenceRefreshNeeded = Notification.Name("com.xomware.float.geofenceRefreshNeeded")
    static let floatNotificationSyncNeeded = Notification.Name("com.xomware.float.notificationSyncNeeded")
}
