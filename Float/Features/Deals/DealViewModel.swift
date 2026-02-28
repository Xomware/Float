import SwiftUI

struct Deal: Identifiable {
    let id: UUID
    var title: String
    var description: String?
    var category: String
    var venueName: String?
    var expiresAt: Date?
    var discountType: String
    var discountValue: Double?
}

@MainActor
class DealViewModel: ObservableObject {
    @Published var deals: [Deal] = []
    @Published var isLoading = false
    
    func loadDeals() async {
        isLoading = true
        defer { isLoading = false }
        Logger.deals.info("Loading deals list")
        // TODO: fetch from Supabase
    }
}
