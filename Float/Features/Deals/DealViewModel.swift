import SwiftUI
import CoreLocation

// MARK: - Models
struct Deal: Identifiable {
    let id: UUID
    var title: String
    var description: String?
    var category: String // "drink", "food", "both", "flash"
    var venueId: UUID
    var venueName: String?
    var expiresAt: Date?
    var startsAt: Date?
    var discountType: String // "percentage", "fixed", "bogo"
    var discountValue: Double?
    var terms: String?
    var distance: Double? // in meters
    var distanceFromUser: Double? // in meters for sorting
    var discountDisplay: String {
        guard let value = discountValue else { return "" }
        switch discountType {
        case "percentage": return "\(Int(value))% OFF"
        case "fixed": return "$\(String(format: "%.2f", value)) OFF"
        case "bogo": return "BUY ONE GET ONE"
        default: return ""
        }
    }
}

struct Venue: Identifiable {
    let id: UUID
    var name: String
    var address: String?
    var phone: String?
    var website: String?
    var hours: String?
    var isOpenNow: Bool = true
    var closingTime: String?
    var isSaved: Bool = false
}

// MARK: - Sort Options
enum DealSortOption: String, CaseIterable {
    case distance = "Distance"
    case expiryTime = "Expiry Time"
    case discountValue = "Discount Value"
    case relevance = "Relevance"
}

// MARK: - Category Filter
enum DealCategory: String, CaseIterable {
    case all = "All"
    case drinks = "Drinks"
    case food = "Food"
    case both = "Both"
    case flash = "Flash Deals"
}

@MainActor
class DealViewModel: ObservableObject {
    @Published var deals: [Deal] = []
    @Published var filteredDeals: [Deal] = []
    @Published var isLoading = false
    @Published var sortOption: DealSortOption = .distance
    @Published var activeFilter: DealCategory = .all
    @Published var currentPage: Int = 1
    @Published var hasMore: Bool = true
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var dealCount: Int = 0
    
    private let pageSize = 20
    private let locationService = LocationService()
    
    init() {
        locationService.startUpdating()
    }
    
    func loadDeals() async {
        isLoading = true
        defer { isLoading = false }
        
        currentPage = 1
        hasMore = true
        deals.removeAll()
        
        await loadMoreDeals()
    }
    
    func loadMoreDeals() async {
        guard !isLoading else { return }
        
        Logger.deals.info("Loading deals page \(currentPage)")
        
        // Simulate loading with mock data for now
        // TODO: Replace with actual Supabase fetch
        let mockDeals = generateMockDeals(page: currentPage, pageSize: pageSize)
        
        if currentPage == 1 {
            deals = mockDeals
        } else {
            deals.append(contentsOf: mockDeals)
        }
        
        dealCount = deals.count
        hasMore = mockDeals.count == pageSize
        currentPage += 1
        
        applyFiltersAndSort()
    }
    
    func applyFiltersAndSort() {
        var result = deals
        
        // Apply category filter
        if activeFilter != .all {
            result = result.filter { deal in
                switch activeFilter {
                case .all: return true
                case .drinks: return deal.category.lowercased() == "drink"
                case .food: return deal.category.lowercased() == "food"
                case .both: return deal.category.lowercased() == "both"
                case .flash: return deal.category.lowercased() == "flash"
                }
            }
        }
        
        // Apply sorting
        result.sort { deal1, deal2 in
            switch sortOption {
            case .distance:
                let dist1 = deal1.distanceFromUser ?? Double.infinity
                let dist2 = deal2.distanceFromUser ?? Double.infinity
                return dist1 < dist2
            case .expiryTime:
                let exp1 = deal1.expiresAt ?? Date.distantFuture
                let exp2 = deal2.expiresAt ?? Date.distantFuture
                return exp1 < exp2
            case .discountValue:
                let val1 = deal1.discountValue ?? 0
                let val2 = deal2.discountValue ?? 0
                return val1 > val2
            case .relevance:
                return deal1.title.count < deal2.title.count // placeholder
            }
        }
        
        filteredDeals = result
    }
    
    func updateFilter(_ category: DealCategory) {
        activeFilter = category
        applyFiltersAndSort()
    }
    
    func updateSort(_ option: DealSortOption) {
        sortOption = option
        applyFiltersAndSort()
    }
    
    // MARK: - Mock Data Generator
    private func generateMockDeals(page: Int, pageSize: Int) -> [Deal] {
        let categories = ["drink", "food", "both", "flash"]
        let discountTypes = ["percentage", "fixed", "bogo"]
        let venues = [
            ("The Daily Brew", "Downtown"), ("Food Court Pro", "Midtown"),
            ("Happy Hour Haven", "Uptown"), ("The Mix", "Westside"),
            ("Late Night Eats", "East Plaza"), ("Cocktail Corner", "North")
        ]
        
        var result: [Deal] = []
        let startIdx = (page - 1) * pageSize
        
        for i in startIdx..<startIdx + pageSize {
            let venueInfo = venues[i % venues.count]
            let expiresIn = TimeInterval(Int.random(in: 1800...86400))
            let distance = Double.random(in: 100...5000)
            
            let deal = Deal(
                id: UUID(),
                title: "Amazing Deal #\(i + 1)",
                description: "Limited time offer - Get \(Int.random(in: 10...50))% off your favorite items!",
                category: categories[i % categories.count],
                venueId: UUID(),
                venueName: venueInfo.0,
                expiresAt: Date().addingTimeInterval(expiresIn),
                startsAt: Date(),
                discountType: discountTypes[i % discountTypes.count],
                discountValue: Double(Int.random(in: 10...50)),
                terms: "Valid today only. Cannot be combined with other offers.",
                distance: distance,
                distanceFromUser: distance
            )
            result.append(deal)
        }
        
        return result
    }
}
