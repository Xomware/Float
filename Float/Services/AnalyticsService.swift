// AnalyticsService.swift
// Float
//
// PostHog analytics integration stub.
// Sprint 6 — Launch Prep
//
// ─── Setup Instructions ────────────────────────────────────────────────────
// 1. Add PostHog via SPM: https://github.com/PostHog/posthog-ios
//    Products needed: PostHog
// 2. Set POSTHOG_API_KEY in your .env file and Info.plist build vars
// 3. Uncomment the import and live code below
// 4. Verify events appear in PostHog dashboard under "Float (iOS)"
// ───────────────────────────────────────────────────────────────────────────

import Foundation
import os.log

// import PostHog   // ← Uncomment after adding PostHog SDK via SPM

// MARK: - Event Catalog

/// Strongly-typed analytics event names.
/// Keep this enum as the single source of truth for all tracked events.
public enum FloatEvent {
    // ── Auth ──────────────────────────────────────────────────────────────
    case signInStarted(method: String)
    case signInSuccess(method: String)
    case signInFailed(method: String, reason: String)
    case signUpCompleted
    case signedOut

    // ── Deals ─────────────────────────────────────────────────────────────
    case dealsViewed(count: Int, latitude: Double, longitude: Double)
    case dealTapped(dealId: String, venueId: String, category: String)
    case dealRedeemed(dealId: String, venueId: String)
    case dealBookmarked(dealId: String)
    case dealUnbookmarked(dealId: String)

    // ── Map ───────────────────────────────────────────────────────────────
    case mapOpened
    case mapRegionChanged(zoom: Double)
    case mapPinTapped(venueId: String)

    // ── Search ────────────────────────────────────────────────────────────
    case searchOpened
    case searchQueried(query: String)
    case searchResultTapped(dealId: String, rank: Int)

    // ── Venue ─────────────────────────────────────────────────────────────
    case venueProfileViewed(venueId: String)

    // ── Profile / Settings ────────────────────────────────────────────────
    case profileViewed
    case notificationsEnabled
    case notificationsDisabled

    // ── Onboarding ────────────────────────────────────────────────────────
    case onboardingStarted
    case onboardingStepCompleted(step: Int)
    case onboardingFinished

    // ── Error ─────────────────────────────────────────────────────────────
    case errorOccurred(domain: String, code: Int, screen: String)

    // ── Internal ──────────────────────────────────────────────────────────
    var name: String {
        switch self {
        case .signInStarted:             return "sign_in_started"
        case .signInSuccess:             return "sign_in_success"
        case .signInFailed:              return "sign_in_failed"
        case .signUpCompleted:           return "sign_up_completed"
        case .signedOut:                 return "signed_out"
        case .dealsViewed:               return "deals_viewed"
        case .dealTapped:                return "deal_tapped"
        case .dealRedeemed:              return "deal_redeemed"
        case .dealBookmarked:            return "deal_bookmarked"
        case .dealUnbookmarked:          return "deal_unbookmarked"
        case .mapOpened:                 return "map_opened"
        case .mapRegionChanged:          return "map_region_changed"
        case .mapPinTapped:              return "map_pin_tapped"
        case .searchOpened:              return "search_opened"
        case .searchQueried:             return "search_queried"
        case .searchResultTapped:        return "search_result_tapped"
        case .venueProfileViewed:        return "venue_profile_viewed"
        case .profileViewed:             return "profile_viewed"
        case .notificationsEnabled:      return "notifications_enabled"
        case .notificationsDisabled:     return "notifications_disabled"
        case .onboardingStarted:         return "onboarding_started"
        case .onboardingStepCompleted:   return "onboarding_step_completed"
        case .onboardingFinished:        return "onboarding_finished"
        case .errorOccurred:             return "error_occurred"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .signInStarted(let method):                       return ["method": method]
        case .signInSuccess(let method):                       return ["method": method]
        case .signInFailed(let method, let reason):            return ["method": method, "reason": reason]
        case .signUpCompleted:                                 return [:]
        case .signedOut:                                       return [:]
        case .dealsViewed(let count, let lat, let lon):        return ["count": count, "latitude": lat, "longitude": lon]
        case .dealTapped(let id, let venue, let cat):          return ["deal_id": id, "venue_id": venue, "category": cat]
        case .dealRedeemed(let id, let venue):                 return ["deal_id": id, "venue_id": venue]
        case .dealBookmarked(let id):                          return ["deal_id": id]
        case .dealUnbookmarked(let id):                        return ["deal_id": id]
        case .mapOpened:                                       return [:]
        case .mapRegionChanged(let zoom):                      return ["zoom": zoom]
        case .mapPinTapped(let venue):                         return ["venue_id": venue]
        case .searchOpened:                                    return [:]
        case .searchQueried(let q):                            return ["query": q]
        case .searchResultTapped(let id, let rank):            return ["deal_id": id, "rank": rank]
        case .venueProfileViewed(let venue):                   return ["venue_id": venue]
        case .profileViewed:                                   return [:]
        case .notificationsEnabled:                            return [:]
        case .notificationsDisabled:                           return [:]
        case .onboardingStarted:                               return [:]
        case .onboardingStepCompleted(let step):               return ["step": step]
        case .onboardingFinished:                              return [:]
        case .errorOccurred(let domain, let code, let screen): return ["domain": domain, "code": code, "screen": screen]
        }
    }
}

// MARK: - AnalyticsService

/// Wraps PostHog for event tracking and user identification.
/// All methods are no-ops until the PostHog SDK is added.
public final class AnalyticsService {

    // MARK: - Shared

    public static let shared = AnalyticsService()
    private init() {}

    // MARK: - Logger (used until PostHog is live)

    private let logger = Logger(subsystem: "com.xomware.float", category: "Analytics")

    // MARK: - Configuration

    /// Call from `FloatApp.init()` before any tracking calls.
    /// `apiKey` should come from Info.plist or environment — never hardcode.
    public func configure(apiKey: String? = nil) {
        let key = apiKey ?? Bundle.main.infoDictionary?["POSTHOG_API_KEY"] as? String ?? "MISSING_KEY"

        // --- LIVE CODE (uncomment after PostHog SDK is added) ---
        // let config = PostHogConfig(apiKey: key, host: "https://app.posthog.com")
        // config.flushAt = 20
        // config.flushInterval = 30
        // config.captureApplicationLifecycleEvents = true
        // config.captureScreenViews = false    // we track screens manually
        // PostHogSDK.shared.setup(config)
        // ---------------------------------------------------------

        logger.info("[Analytics] configure() called — stub, no-op. key prefix=\(String(key.prefix(6)))")
    }

    // MARK: - User Identity

    /// Identify the signed-in user. Call after successful login.
    public func identify(userId: String, traits: [String: Any] = [:]) {
        // PostHogSDK.shared.identify(userId, userProperties: traits)

        logger.debug("[Analytics] identify userId=\(userId, privacy: .private) traits=\(traits)")
    }

    /// Reset identity on sign-out.
    public func reset() {
        // PostHogSDK.shared.reset()

        logger.debug("[Analytics] reset")
    }

    // MARK: - Event Tracking

    /// Track a strongly-typed FloatEvent.
    public func track(_ event: FloatEvent) {
        track(event.name, properties: event.properties)
    }

    /// Track a raw named event with optional properties.
    public func track(_ name: String, properties: [String: Any] = [:]) {
        // PostHogSDK.shared.capture(name, properties: properties)

        logger.debug("[Analytics] track name=\(name) properties=\(properties)")
    }

    // MARK: - Screen Tracking

    /// Track a screen view. Call from `.onAppear` or navigation callbacks.
    public func screen(_ name: String, properties: [String: Any] = [:]) {
        // PostHogSDK.shared.screen(name, properties: properties)

        logger.debug("[Analytics] screen name=\(name) properties=\(properties)")
    }

    // MARK: - Super Properties

    /// Register persistent properties sent with every subsequent event.
    public func register(superProperties: [String: Any]) {
        // PostHogSDK.shared.register(superProperties)

        logger.debug("[Analytics] register superProperties=\(superProperties)")
    }
}

// MARK: - SwiftUI View Extension

import SwiftUI

public extension View {
    /// Automatically track a screen view when this view appears.
    func trackScreen(_ name: String, properties: [String: Any] = [:]) -> some View {
        self.onAppear {
            AnalyticsService.shared.screen(name, properties: properties)
        }
    }
}
