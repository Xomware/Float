import SwiftUI
import Supabase
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "FloatApp")

// import FirebaseCore        // ← Uncomment after adding Firebase SDK
// import PostHog             // ← Uncomment after adding PostHog SDK

@main
struct FloatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authService = AuthService()

    init() {
        configureSDKs()
    }

    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authService)
                .environmentObject(notificationService)
                .environmentObject(geofenceManager)
                .preferredColorScheme(.dark)
                .task {
                    // Request notification permission on launch
                    await notificationService.requestPermissionAndRegister()
                }
                .onReceive(NotificationCenter.default.publisher(for: .floatAPNsTokenReceived)) { note in
                    handleAPNsToken(note)
                }
                .onReceive(NotificationCenter.default.publisher(for: .floatGeofenceRefreshNeeded)) { _ in
                    handleGeofenceRefresh()
                }
                .onReceive(NotificationCenter.default.publisher(for: .floatNotificationSyncNeeded)) { _ in
                    handleNotificationSync()
                }
                .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
                    if isAuthenticated {
                        onUserSignedIn()
                    } else {
                        onUserSignedOut()
                    }
                }
        }
    }

    // MARK: - Auth Event Handlers

    private func onUserSignedIn() {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        logger.info("User signed in — registering push services for \(userId)")

        Task {
            // Retry any pending token registration that failed earlier
            await notificationService.retryPendingTokenRegistration()
            // Kick off geofence setup
            await geofenceManager.refreshGeofences(for: userId)
        }
    }

    private func onUserSignedOut() {
        guard let userId = authService.session?.user.id.uuidString else {
            geofenceManager.stopAllMonitoring()
            return
        }
        Task {
            await notificationService.deactivateTokens(for: userId)
            geofenceManager.stopAllMonitoring()
        }
    }

    // MARK: - APNs Token Handler

    private func handleAPNsToken(_ notification: Foundation.Notification) {
        guard
            let tokenData = notification.userInfo?["device_token_data"] as? Data,
            let userId = authService.currentUser?.id.uuidString
        else {
            // User not yet authenticated — store for retry after sign-in
            logger.warning("APNs token received but user not authenticated — will retry after sign-in")
            return
        }

        Task {
            await notificationService.registerDeviceToken(tokenData, userId: userId)
        }
    }

    // MARK: - Background Task Handlers

    private func handleGeofenceRefresh() {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        Task {
            await geofenceManager.refreshGeofences(for: userId)
        }
    }

    private func handleNotificationSync() {
        guard let userId = authService.currentUser?.id.uuidString else { return }
        Task {
            // Sync any outstanding scheduled notifications and retry pending tokens
            await notificationService.retryPendingTokenRegistration()
            await notificationService.refreshPendingNotifications()
            await geofenceManager.refreshGeofences(for: userId)
        }
    }

    // MARK: - SDK Initialization

    /// Central SDK bootstrap. Called once at app launch before any scene is created.
    private func configureSDKs() {
        // ── Firebase (Crashlytics) ────────────────────────────────────────
        // FirebaseApp.configure()              // must come before CrashlyticsService
        CrashlyticsService.shared.configure()

        // ── PostHog (Analytics) ───────────────────────────────────────────
        // Reads POSTHOG_API_KEY from Info.plist — set in Xcode build settings
        AnalyticsService.shared.configure()
    }
}
