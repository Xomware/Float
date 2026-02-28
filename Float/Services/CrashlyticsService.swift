// CrashlyticsService.swift
// Float
//
// Firebase Crashlytics integration stub.
// Sprint 6 — Launch Prep
//
// ─── Setup Instructions ────────────────────────────────────────────────────
// 1. Add FirebaseSDK via SPM: https://github.com/firebase/firebase-ios-sdk
//    Products needed: FirebaseAnalytics, FirebaseCrashlytics
// 2. Download GoogleService-Info.plist from Firebase console and add to Float/Resources/
// 3. Enable Crashlytics in Firebase console for your project
// 4. Uncomment the import and live code below
// 5. Run once with a test crash to verify the dashboard receives events
// ───────────────────────────────────────────────────────────────────────────

import Foundation
import os.log

// import FirebaseCrashlytics   // ← Uncomment after adding Firebase SDK

/// Wraps Firebase Crashlytics for non-fatal error reporting and crash metadata.
/// All methods are no-ops until the Firebase SDK is added.
public final class CrashlyticsService {

    // MARK: - Shared

    public static let shared = CrashlyticsService()
    private init() {}

    // MARK: - Logger (used until Crashlytics is live)

    private let logger = Logger(subsystem: "com.xomware.float", category: "Crashlytics")

    // MARK: - Configuration

    /// Call from `FloatApp.init()` after `FirebaseApp.configure()`.
    public func configure() {
        // --- LIVE CODE (uncomment after Firebase SDK is added) ---
        // FirebaseApp.configure()
        // Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(!isDebug)
        // ---------------------------------------------------------

        logger.info("[Crashlytics] configure() called — stub, no-op until Firebase SDK added")
    }

    // MARK: - User Identity

    /// Associate the current Supabase user with crash reports.
    public func setUser(id: String, email: String? = nil) {
        // Crashlytics.crashlytics().setUserID(id)
        // if let email { Crashlytics.crashlytics().setCustomValue(email, forKey: "user_email") }

        logger.debug("[Crashlytics] setUser id=\(id, privacy: .private)")
    }

    /// Clear user identity on sign-out.
    public func clearUser() {
        // Crashlytics.crashlytics().setUserID("")

        logger.debug("[Crashlytics] clearUser")
    }

    // MARK: - Non-fatal Errors

    /// Report a non-fatal error (e.g. network timeout, data decode failure).
    public func record(error: Error, context: [String: String] = [:]) {
        // let crashlytics = Crashlytics.crashlytics()
        // context.forEach { crashlytics.setCustomValue($1, forKey: $0) }
        // crashlytics.record(error: error)

        logger.error("[Crashlytics] record error=\(error.localizedDescription) context=\(context)")
    }

    /// Log a breadcrumb message visible in crash reports.
    public func log(_ message: String) {
        // Crashlytics.crashlytics().log(message)

        logger.debug("[Crashlytics] breadcrumb: \(message)")
    }

    /// Attach arbitrary metadata to crash reports.
    public func setCustomValue(_ value: String, forKey key: String) {
        // Crashlytics.crashlytics().setCustomValue(value, forKey: key)

        logger.debug("[Crashlytics] customValue key=\(key) value=\(value, privacy: .private)")
    }

    // MARK: - Test Crash (DEBUG only)

#if DEBUG
    /// Force a crash to verify Crashlytics is wired up correctly.
    /// Remove before release or gate behind a hidden dev menu.
    public func testCrash() {
        logger.warning("[Crashlytics] testCrash() called — would crash here if SDK were active")
        // fatalError("Test crash — Crashlytics verification")
    }
#endif

    // MARK: - Private Helpers

    private var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
}
