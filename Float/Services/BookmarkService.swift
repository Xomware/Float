// BookmarkService.swift
// Float

import Foundation
import Supabase
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Bookmarks")

// MARK: - BookmarkService

/// Manages deal and venue bookmarks, syncing with Supabase.
/// Venue bookmarks are used by the `notify-favorites` edge function
/// to send push notifications when a bookmarked venue posts a new deal.
@MainActor
class BookmarkService: ObservableObject {
    static let shared = BookmarkService()

    // MARK: - Published State
    @Published var savedDealIds: Set<UUID> = []
    @Published var savedVenueIds: Set<UUID> = []
    @Published var isLoading = false

    // MARK: - Private
    private let supabaseClient = SupabaseClientService.shared.client
    private let userDefaults = UserDefaults.standard
    private let savedDealsKey  = "float_saved_deals"
    private let savedVenuesKey = "float_saved_venues"

    init() {
        loadCachedBookmarks()
    }

    // MARK: - Deal Bookmarks

    func saveDeal(_ dealId: UUID) async {
        savedDealIds.insert(dealId)
        cacheSavedDeals()

        do {
            try await supabaseClient
                .from("bookmarks")
                .upsert(["deal_id": dealId.uuidString], onConflict: "user_id,deal_id")
                .execute()
            logger.info("Deal bookmarked (server): \(dealId)")
        } catch {
            logger.error("Failed to save deal bookmark on server: \(error)")
        }
    }

    func unsaveDeal(_ dealId: UUID) async {
        savedDealIds.remove(dealId)
        cacheSavedDeals()

        do {
            try await supabaseClient
                .from("bookmarks")
                .delete()
                .eq("deal_id", value: dealId.uuidString)
                .execute()
            logger.info("Deal unbookmarked (server): \(dealId)")
        } catch {
            logger.error("Failed to remove deal bookmark on server: \(error)")
        }
    }

    // MARK: - Venue Bookmarks
    // NOTE: Venue bookmarks are synced to Supabase so `notify-favorites`
    // can find which users to notify when a venue posts a new deal.

    func saveVenue(_ venueId: UUID) async {
        savedVenueIds.insert(venueId)
        cacheSavedVenues()

        do {
            try await supabaseClient
                .from("bookmarks")
                .upsert(["venue_id": venueId.uuidString], onConflict: "user_id,venue_id")
                .execute()
            logger.info("Venue bookmarked (server): \(venueId)")
        } catch {
            logger.error("Failed to save venue bookmark on server: \(error)")
        }
    }

    func unsaveVenue(_ venueId: UUID) async {
        savedVenueIds.remove(venueId)
        cacheSavedVenues()

        do {
            try await supabaseClient
                .from("bookmarks")
                .delete()
                .eq("venue_id", value: venueId.uuidString)
                .execute()
            logger.info("Venue unbookmarked (server): \(venueId)")
        } catch {
            logger.error("Failed to remove venue bookmark on server: \(error)")
        }
    }

    // MARK: - Quick Checks

    func isDealSaved(_ dealId: UUID) -> Bool { savedDealIds.contains(dealId) }
    func isVenueSaved(_ venueId: UUID) -> Bool { savedVenueIds.contains(venueId) }

    // MARK: - Sync from Server

    func syncBookmarks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            struct BookmarkRow: Decodable {
                let dealId: UUID?
                let venueId: UUID?
                enum CodingKeys: String, CodingKey {
                    case dealId = "deal_id"
                    case venueId = "venue_id"
                }
            }

            let rows: [BookmarkRow] = try await supabaseClient
                .from("bookmarks")
                .select("deal_id, venue_id")
                .execute()
                .value

            savedDealIds  = Set(rows.compactMap(\.dealId))
            savedVenueIds = Set(rows.compactMap(\.venueId))
            cacheSavedDeals()
            cacheSavedVenues()
            logger.info("Bookmarks synced from server: \(rows.count) rows")
        } catch {
            logger.error("Failed to sync bookmarks from server: \(error)")
            // Fall back to local cache
            loadCachedBookmarks()
        }
    }

    // MARK: - Local Caching

    private func loadCachedBookmarks() {
        if let dealsData = userDefaults.data(forKey: savedDealsKey),
           let dealsArray = try? JSONDecoder().decode([String].self, from: dealsData) {
            savedDealIds = Set(dealsArray.compactMap { UUID(uuidString: $0) })
        }
        if let venuesData = userDefaults.data(forKey: savedVenuesKey),
           let venuesArray = try? JSONDecoder().decode([String].self, from: venuesData) {
            savedVenueIds = Set(venuesArray.compactMap { UUID(uuidString: $0) })
        }
    }

    private func cacheSavedDeals() {
        if let encoded = try? JSONEncoder().encode(Array(savedDealIds).map { $0.uuidString }) {
            userDefaults.set(encoded, forKey: savedDealsKey)
        }
    }

    private func cacheSavedVenues() {
        if let encoded = try? JSONEncoder().encode(Array(savedVenueIds).map { $0.uuidString }) {
            userDefaults.set(encoded, forKey: savedVenuesKey)
        }
    }
}
