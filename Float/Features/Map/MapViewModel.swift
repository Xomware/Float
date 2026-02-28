import SwiftUI
import MapKit
import Combine

struct DealPin: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let venueName: String
    let dealTitle: String
    let category: String
    let expiresAt: Date
}

@MainActor
class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var dealPins: [DealPin] = []
    @Published var selectedPin: DealPin?
    
    func loadNearbyDeals() async {
        // TODO: Call Supabase get_deals_nearby RPC
        Logger.deals.info("Loading nearby deals")
    }
    
    func selectPin(_ pin: DealPin) {
        withAnimation(.spring()) { selectedPin = selectedPin?.id == pin.id ? nil : pin }
    }
}
