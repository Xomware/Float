import Foundation
import Supabase

@MainActor
class BookmarkService: ObservableObject {
    static let shared = BookmarkService()
    
    @Published var savedDealIds: Set<UUID> = []
    @Published var savedVenueIds: Set<UUID> = []
    @Published var isLoading = false
    
    private let supabaseClient = SupabaseClientService.shared.client
    private let userDefaults = UserDefaults.standard
    
    // Cache keys
    private let savedDealsKey = "float_saved_deals"
    private let savedVenuesKey = "float_saved_venues"
    
    init() {
        loadCachedBookmarks()
    }
    
    // MARK: - Deal Bookmarks
    func saveDeal(_ dealId: UUID) async {
        // Update local cache
        savedDealIds.insert(dealId)
        cacheSavedDeals()
        
        // Sync with Supabase (would do in production)
        // try? await supabaseClient.from("bookmarks")
        //     .insert(["deal_id": dealId.uuidString, "user_id": userId])
        //     .execute()
        
        Logger.deals.info("Deal bookmarked: \(dealId)")
    }
    
    func unsaveDeal(_ dealId: UUID) async {
        // Remove from local cache
        savedDealIds.remove(dealId)
        cacheSavedDeals()
        
        // Sync with Supabase (would do in production)
        // try? await supabaseClient.from("bookmarks")
        //     .delete()
        //     .eq("deal_id", value: dealId.uuidString)
        //     .execute()
        
        Logger.deals.info("Deal unbookmarked: \(dealId)")
    }
    
    // MARK: - Venue Bookmarks
    func saveVenue(_ venueId: UUID) async {
        // Update local cache
        savedVenueIds.insert(venueId)
        cacheSavedVenues()
        
        // Sync with Supabase (would do in production)
        // try? await supabaseClient.from("bookmarks")
        //     .insert(["venue_id": venueId.uuidString, "user_id": userId])
        //     .execute()
        
        Logger.deals.info("Venue bookmarked: \(venueId)")
    }
    
    func unsaveVenue(_ venueId: UUID) async {
        // Remove from local cache
        savedVenueIds.remove(venueId)
        cacheSavedVenues()
        
        // Sync with Supabase (would do in production)
        // try? await supabaseClient.from("bookmarks")
        //     .delete()
        //     .eq("venue_id", value: venueId.uuidString)
        //     .execute()
        
        Logger.deals.info("Venue unbookmarked: \(venueId)")
    }
    
    // MARK: - Quick Checks
    func isDealSaved(_ dealId: UUID) -> Bool {
        savedDealIds.contains(dealId)
    }
    
    func isVenueSaved(_ venueId: UUID) -> Bool {
        savedVenueIds.contains(venueId)
    }
    
    // MARK: - Sync from Server
    func syncBookmarks() async {
        isLoading = true
        defer { isLoading = false }
        
        // In production, this would fetch bookmarks from Supabase
        // For now, just work with local cache
        loadCachedBookmarks()
        Logger.deals.info("Bookmarks synced")
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
        let dealsArray = Array(savedDealIds).map { $0.uuidString }
        if let encoded = try? JSONEncoder().encode(dealsArray) {
            userDefaults.set(encoded, forKey: savedDealsKey)
        }
    }
    
    private func cacheSavedVenues() {
        let venuesArray = Array(savedVenueIds).map { $0.uuidString }
        if let encoded = try? JSONEncoder().encode(venuesArray) {
            userDefaults.set(encoded, forKey: savedVenuesKey)
        }
    }
}
