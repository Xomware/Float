import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [Deal] = []
    @Published var venueResults: [Venue] = []
    @Published var recentSearches: [String] = []
    @Published var isLoading = false
    @Published var suggestedCategories = ["drink", "food", "combo", "happy_hour", "flash_deal"]
    
    private var searchTask: Task<Void, Never>?
    private let userDefaults = UserDefaults.standard
    private let recentSearchesKey = "float_recent_searches"
    
    init() {
        loadRecentSearches()
    }
    
    // MARK: - Search Logic
    func performSearch(_ query: String) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            venueResults = []
            return
        }
        
        // Debounce search
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            
            if !Task.isCancelled {
                // Mock search - in production would query Supabase
                let queryLower = query.lowercased()
                
                // Filter deals
                self.searchResults = mockDeals.filter { deal in
                    deal.title.lowercased().contains(queryLower) ||
                    deal.description?.lowercased().contains(queryLower) ?? false ||
                    deal.category.lowercased().contains(queryLower)
                }
                
                // Filter venues
                self.venueResults = mockVenues.filter { venue in
                    venue.name.lowercased().contains(queryLower) ||
                    venue.address.lowercased().contains(queryLower)
                }
                
                // Add to recent searches
                if !queryLower.isEmpty {
                    addRecentSearch(query)
                }
            }
        }
    }
    
    // MARK: - Recent Searches
    private func loadRecentSearches() {
        if let data = userDefaults.data(forKey: recentSearchesKey),
           let searches = try? JSONDecoder().decode([String].self, from: data) {
            recentSearches = searches
        }
    }
    
    private func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        
        // Remove if already exists
        recentSearches.removeAll { $0 == trimmed }
        
        // Add to front
        recentSearches.insert(trimmed, at: 0)
        
        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches.removeLast()
        }
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            userDefaults.set(encoded, forKey: recentSearchesKey)
        }
    }
    
    func clearRecentSearches() {
        recentSearches = []
        userDefaults.removeObject(forKey: recentSearchesKey)
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                FloatColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: FloatSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(FloatColors.textSecondary)
                        
                        TextField("Search deals & venues", text: $viewModel.searchQuery)
                            .font(FloatFont.body())
                            .foregroundStyle(FloatColors.textPrimary)
                            .focused($isFocused)
                            .onChange(of: viewModel.searchQuery) { _, newValue in
                                viewModel.performSearch(newValue)
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(FloatColors.textSecondary)
                            }
                        }
                    }
                    .padding(FloatSpacing.md)
                    .background(FloatColors.cardBackground)
                    
                    Divider()
                        .background(FloatColors.textSecondary.opacity(0.2))
                    
                    // Content
                    ScrollView {
                        if viewModel.searchQuery.isEmpty {
                            emptyStateView
                        } else if viewModel.searchResults.isEmpty && viewModel.venueResults.isEmpty {
                            noResultsView
                        } else {
                            searchResultsView
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: FloatSpacing.lg) {
            // Suggested Categories
            if !viewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: FloatSpacing.md) {
                    Text("Recent Searches")
                        .font(FloatFont.headline())
                        .foregroundStyle(FloatColors.textPrimary)
                        .padding(.horizontal, FloatSpacing.md)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: FloatSpacing.sm) {
                            ForEach(viewModel.recentSearches, id: \.self) { search in
                                Button(action: {
                                    viewModel.searchQuery = search
                                    viewModel.performSearch(search)
                                }) {
                                    Text(search)
                                        .font(FloatFont.callout())
                                        .foregroundStyle(FloatColors.textPrimary)
                                        .padding(.horizontal, FloatSpacing.md)
                                        .padding(.vertical, FloatSpacing.sm)
                                        .background(FloatColors.cardBackground)
                                        .cornerRadius(FloatSpacing.badgeRadius)
                                }
                            }
                        }
                        .padding(.horizontal, FloatSpacing.md)
                    }
                    
                    Button(action: { viewModel.clearRecentSearches() }) {
                        Text("Clear Recent Searches")
                            .font(FloatFont.callout())
                            .foregroundStyle(FloatColors.accent)
                    }
                    .padding(.horizontal, FloatSpacing.md)
                }
                .padding(.vertical, FloatSpacing.lg)
            }
            
            VStack(alignment: .leading, spacing: FloatSpacing.md) {
                Text("Suggested Categories")
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.textPrimary)
                
                Wrap(spacing: FloatSpacing.sm) {
                    ForEach(viewModel.suggestedCategories, id: \.self) { category in
                        Button(action: {
                            viewModel.searchQuery = category
                            viewModel.performSearch(category)
                        }) {
                            Text(category.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(FloatFont.callout())
                                .foregroundStyle(.white)
                                .padding(.horizontal, FloatSpacing.md)
                                .padding(.vertical, FloatSpacing.sm)
                                .background(FloatColors.primary)
                                .cornerRadius(FloatSpacing.badgeRadius)
                        }
                    }
                }
            }
            .padding(FloatSpacing.md)
            
            Spacer()
        }
        .padding(.top, FloatSpacing.lg)
    }
    
    @ViewBuilder
    private var noResultsView: some View {
        VStack(spacing: FloatSpacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(FloatColors.textSecondary)
            
            Text("No Results Found")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.textPrimary)
            
            Text("Try searching for a different deal, venue, or category")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FloatSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(FloatSpacing.lg)
    }
    
    @ViewBuilder
    private var searchResultsView: some View {
        LazyVStack(spacing: FloatSpacing.md) {
            // Deals Section
            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: FloatSpacing.md) {
                    Text("Deals")
                        .font(FloatFont.headline())
                        .foregroundStyle(FloatColors.textPrimary)
                        .padding(.horizontal, FloatSpacing.md)
                    
                    ForEach(viewModel.searchResults.prefix(5)) { deal in
                        NavigationLink(destination: DealDetailView(deal: deal)) {
                            SearchDealCard(deal: deal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, FloatSpacing.md)
            }
            
            // Venues Section
            if !viewModel.venueResults.isEmpty {
                VStack(alignment: .leading, spacing: FloatSpacing.md) {
                    Text("Venues")
                        .font(FloatFont.headline())
                        .foregroundStyle(FloatColors.textPrimary)
                        .padding(.horizontal, FloatSpacing.md)
                    
                    ForEach(viewModel.venueResults.prefix(5)) { venue in
                        SearchVenueCard(venue: venue)
                    }
                }
                .padding(.top, FloatSpacing.md)
            }
        }
        .padding(FloatSpacing.md)
    }
}

struct SearchDealCard: View {
    let deal: Deal
    
    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                HStack(spacing: FloatSpacing.md) {
                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        Text(deal.title)
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.textPrimary)
                            .lineLimit(2)
                        
                        if let venueName = deal.venueName {
                            Text(venueName)
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    FloatBadge(text: deal.category.uppercased())
                }
            }
        }
    }
}

struct SearchVenueCard: View {
    let venue: Venue
    
    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                HStack(spacing: FloatSpacing.md) {
                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        Text(venue.name)
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.textPrimary)
                        
                        Text(venue.address)
                            .font(FloatFont.callout())
                            .foregroundStyle(FloatColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: FloatSpacing.xs) {
                        HStack(spacing: FloatSpacing.xs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(FloatColors.warning)
                            
                            Text(String(format: "%.1f", venue.rating))
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textPrimary)
                        }
                    }
                }
            }
        }
    }
}

// Wrap component for grid layout
struct Wrap<Content: View>: View {
    let spacing: CGFloat
    let content: [Content]
    
    init(spacing: CGFloat = 8, @ViewBuilder builder: () -> [Content]) {
        self.spacing = spacing
        self.content = builder()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            var rowContent: [Content] = []
            
            ForEach(0..<content.count, id: \.self) { index in
                HStack(spacing: spacing) {
                    content[index]
                    Spacer()
                }
            }
        }
    }
}

// Mock data for preview
struct Venue: Identifiable {
    let id: UUID
    let name: String
    let address: String
    let rating: Double
}

let mockVenues = [
    Venue(id: UUID(), name: "Honky Tonk Central", address: "118 2nd Ave S", rating: 4.6),
    Venue(id: UUID(), name: "The Bluebird Cafe", address: "4104 Nolensville Pike", rating: 4.8),
]

let mockDeals = [
    Deal(id: UUID(), title: "Happy Hour: $4 Wells", description: "$4 domestic wells 4-7pm", category: "drink", venueName: "Honky Tonk Central", expiresAt: Date().addingTimeInterval(3600), discountType: "fixed", discountValue: 4),
    Deal(id: UUID(), title: "2-for-1 Margaritas", description: "Buy one, get one free", category: "drink", venueName: "El Paso Bar", expiresAt: Date().addingTimeInterval(3600), discountType: "bogo", discountValue: nil),
]

#Preview {
    SearchView()
        .environment(\.colorScheme, .dark)
}
