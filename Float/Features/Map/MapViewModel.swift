import SwiftUI
import MapKit
import Combine
import CoreLocation

struct DealPin: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let venueName: String
    let dealTitle: String
    let category: String // "drink", "food", "both", "flash"
    let expiresAt: Date
    let deal: Deal
    
    var categoryColor: Color {
        switch category.lowercased() {
        case "drink": return FloatColors.drinkColor
        case "food": return FloatColors.foodColor
        case "both": return FloatColors.comboColor
        case "flash": return FloatColors.eventColor
        default: return FloatColors.primary
        }
    }
}

@MainActor
class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var dealPins: [DealPin] = []
    @Published var filteredPins: [DealPin] = []
    @Published var selectedPin: DealPin?
    @Published var isLoading = false
    @Published var activeNowOnly: Bool = false
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isRefreshing = false
    
    private let locationService = LocationService()
    private var locationTask: Task<Void, Never>?
    
    init() {
        setupLocationTracking()
    }
    
    private func setupLocationTracking() {
        locationService.startUpdating()
        
        // Watch for location updates
        locationTask = Task {
            while !Task.isCancelled {
                userLocation = locationService.currentLocation?.coordinate
                
                if let location = userLocation {
                    updateMapRegion(to: location)
                }
                
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second updates
            }
        }
    }
    
    private func updateMapRegion(to coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.3)) {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func loadNearbyDeals() async {
        isLoading = true
        defer { isLoading = false }
        
        Logger.deals.info("Loading nearby deals from map")
        
        // TODO: Call Supabase nearby_deals RPC with user coordinates
        // For now, generate mock data
        
        guard let userLocation = locationService.currentLocation?.coordinate else {
            Logger.deals.warning("No user location available")
            return
        }
        
        let mockDeals = generateMockMapDeals(centerCoordinate: userLocation)
        
        dealPins = mockDeals.map { deal in
            let randomOffset = (Double.random(in: -0.01...0.01), Double.random(in: -0.01...0.01))
            return DealPin(
                id: deal.id,
                coordinate: CLLocationCoordinate2D(
                    latitude: userLocation.latitude + randomOffset.0,
                    longitude: userLocation.longitude + randomOffset.1
                ),
                venueName: deal.venueName ?? "Unknown Venue",
                dealTitle: deal.title,
                category: deal.category,
                expiresAt: deal.expiresAt ?? Date(),
                deal: deal
            )
        }
        
        applyFilters()
    }
    
    func refreshDeals() async {
        isRefreshing = true
        defer { isRefreshing = false }
        await loadNearbyDeals()
    }
    
    func toggleActiveNowFilter() {
        activeNowOnly.toggle()
        applyFilters()
    }
    
    private func applyFilters() {
        var filtered = dealPins
        
        if activeNowOnly {
            let now = Date()
            filtered = filtered.filter { pin in
                guard let startsAt = pin.deal.startsAt else { return true }
                return startsAt <= now && pin.expiresAt > now
            }
        }
        
        filteredPins = filtered
    }
    
    func selectPin(_ pin: DealPin) {
        withAnimation(.spring()) {
            selectedPin = selectedPin?.id == pin.id ? nil : pin
        }
    }
    
    deinit {
        locationTask?.cancel()
        locationService.stopUpdating()
    }
    
    // MARK: - Mock Data
    private func generateMockMapDeals(centerCoordinate: CLLocationCoordinate2D) -> [Deal] {
        let categories = ["drink", "food", "both", "flash"]
        let venues = [
            "The Daily Brew", "Food Court Pro", "Happy Hour Haven",
            "The Mix", "Late Night Eats", "Cocktail Corner"
        ]
        
        var deals: [Deal] = []
        for i in 0..<8 {
            let deal = Deal(
                id: UUID(),
                title: "Deal #\(i + 1): \(["Half Off", "Buy One Get One", "$5 Off", "Free Drink"][i % 4])",
                description: "Limited time offer!",
                category: categories[i % categories.count],
                venueId: UUID(),
                venueName: venues[i % venues.count],
                expiresAt: Date().addingTimeInterval(Double.random(in: 1800...86400)),
                startsAt: Date().addingTimeInterval(Double.random(in: -3600...0)),
                discountType: ["percentage", "bogo", "fixed"][i % 3],
                discountValue: Double(Int.random(in: 5...50)),
                terms: "Valid today only",
                distanceFromUser: Double.random(in: 100...5000)
            )
            deals.append(deal)
        }
        return deals
    }
}
