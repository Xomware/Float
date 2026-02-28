import SwiftUI
import Supabase

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
                .preferredColorScheme(.dark)
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
