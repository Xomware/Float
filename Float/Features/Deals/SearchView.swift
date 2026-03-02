// SearchView.swift
// Float

import SwiftUI

// MARK: - VenueSearchViewModel

@MainActor
final class VenueSearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var dealResults: [Deal] = []
    @Published var venueResults: [Venue] = []
    @Published var isSearching = false
    @Published var recentSearches: [String] = []
    @Published var hasSearched = false

    private var searchTask: Task<Void, Never>?

    let trendingSearches = ["happy hour", "taco tuesday", "trivia night", "wine wednesday", "brunch deals"]

    init() {
        loadRecentSearches()
    }

    func performSearch() {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            dealResults = []
            venueResults = []
            hasSearched = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            guard !Task.isCancelled else { return }
            isSearching = true
            defer { isSearching = false }

            let queryLower = trimmed.lowercased()
            dealResults = mockDeals.filter {
                $0.title.lowercased().contains(queryLower) ||
                ($0.description?.lowercased().contains(queryLower) ?? false) ||
                ($0.venueName?.lowercased().contains(queryLower) ?? false) ||
                $0.category.lowercased().contains(queryLower)
            }
            venueResults = mockVenues.filter {
                $0.name.lowercased().contains(queryLower) ||
                ($0.address?.lowercased().contains(queryLower) ?? false)
            }
            hasSearched = true
            AnalyticsService.shared.track(.searchQueried(query: query))
        }
    }

    func addRecentSearch(_ term: String) {
        let trimmedTerm = term.trimmingCharacters(in: .whitespaces)
        guard !trimmedTerm.isEmpty else { return }
        recentSearches.removeAll { $0 == trimmedTerm }
        recentSearches.insert(trimmedTerm, at: 0)
        if recentSearches.count > 10 { recentSearches = Array(recentSearches.prefix(10)) }
        saveRecentSearches()
    }

    func removeRecentSearch(_ term: String) {
        recentSearches.removeAll { $0 == term }
        saveRecentSearches()
    }

    func clearAllRecent() {
        recentSearches = []
        saveRecentSearches()
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "float_recent_searches") ?? []
    }

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "float_recent_searches")
    }
}

// MARK: - SearchView (VenueSearch)

struct SearchView: View {
    @StateObject private var viewModel = VenueSearchViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                if viewModel.query.isEmpty {
                    idleView
                } else if viewModel.isSearching {
                    searchingView
                } else {
                    resultsView
                }
            }
            .background(FloatColors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            AnalyticsService.shared.track(.searchOpened)
            isFocused = true
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: FloatSpacing.sm) {
            HStack(spacing: FloatSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)

                TextField("Search deals and venues…", text: $viewModel.query)
                    .focused($isFocused)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    .submitLabel(.search)
                    .onChange(of: viewModel.query) { _ in viewModel.performSearch() }
                    .onSubmit { viewModel.addRecentSearch(viewModel.query) }

                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                        isFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(10)
            .background(FloatColors.adaptiveCardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, FloatSpacing.md)
        .padding(.vertical, FloatSpacing.sm)
    }

    // MARK: - Idle View

    private var idleView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FloatSpacing.lg) {
                // Recent searches
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        HStack {
                            Text("Recent")
                                .font(FloatFont.headline())
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                            Spacer()
                            Button("Clear") { viewModel.clearAllRecent() }
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.primary)
                        }
                        .padding(.horizontal, FloatSpacing.md)

                        ForEach(viewModel.recentSearches, id: \.self) { term in
                            recentRow(term)
                        }
                    }
                }

                // Trending
                VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                    Text("Trending")
                        .font(FloatFont.headline())
                        .foregroundStyle(FloatColors.adaptiveTextPrimary)
                        .padding(.horizontal, FloatSpacing.md)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: FloatSpacing.sm) {
                            ForEach(viewModel.trendingSearches, id: \.self) { term in
                                Button {
                                    viewModel.query = term
                                    viewModel.performSearch()
                                } label: {
                                    HStack(spacing: FloatSpacing.xs) {
                                        Image(systemName: "flame.fill")
                                            .font(.caption)
                                            .foregroundStyle(FloatColors.warning)
                                        Text(term)
                                            .font(FloatFont.caption(.semibold))
                                            .foregroundStyle(FloatColors.adaptiveTextPrimary)
                                    }
                                    .padding(.horizontal, FloatSpacing.sm)
                                    .padding(.vertical, 8)
                                    .background(FloatColors.adaptiveCardBackground)
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, FloatSpacing.md)
                    }
                }
            }
            .padding(.vertical, FloatSpacing.md)
        }
    }

    @ViewBuilder
    private func recentRow(_ term: String) -> some View {
        Button {
            viewModel.query = term
            viewModel.performSearch()
        } label: {
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    .frame(width: 20)
                Text(term)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                Spacer()
                Button {
                    viewModel.removeRecentSearch(term)
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                }
                .accessibilityLabel("Remove \(term) from recent searches")
            }
            .padding(.horizontal, FloatSpacing.md)
            .padding(.vertical, FloatSpacing.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Searching

    private var searchingView: some View {
        VStack(spacing: FloatSpacing.lg) {
            Spacer()
            ProgressView().tint(FloatColors.primary)
            Text("Searching…")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
            Spacer()
        }
    }

    // MARK: - Results

    private var resultsView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                let totalResults = viewModel.dealResults.count + viewModel.venueResults.count

                if totalResults == 0 {
                    emptyResults
                } else {
                    Text("\(totalResults) result\(totalResults == 1 ? "" : "s") for \"\(viewModel.query)\"")
                        .font(FloatFont.caption())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        .padding(.horizontal, FloatSpacing.md)
                        .padding(.vertical, FloatSpacing.sm)

                    // Deal results
                    if !viewModel.dealResults.isEmpty {
                        sectionHeader("Deals", count: viewModel.dealResults.count,
                                      icon: "tag.fill", color: FloatColors.primary)

                        ForEach(Array(viewModel.dealResults.enumerated()), id: \.element.id) { index, deal in
                            NavigationLink(destination: DealDetailView(deal: deal)) {
                                SearchDealRow(deal: deal)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded {
                                viewModel.addRecentSearch(viewModel.query)
                                AnalyticsService.shared.track(.searchResultTapped(dealId: deal.id.uuidString, rank: index))
                            })
                            Divider()
                                .padding(.leading, FloatSpacing.xl + FloatSpacing.md)
                        }
                    }

                    // Venue results
                    if !viewModel.venueResults.isEmpty {
                        sectionHeader("Venues", count: viewModel.venueResults.count,
                                      icon: "building.2.fill", color: FloatColors.accent)

                        ForEach(viewModel.venueResults) { venue in
                            NavigationLink(destination: VenueProfileView(venueId: venue.id, venueName: venue.name)) {
                                SearchVenueRow(venue: venue)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            Divider()
                                .padding(.leading, FloatSpacing.xl + FloatSpacing.md)
                        }
                    }
                }
            }
        }
    }

    private var emptyResults: some View {
        VStack(spacing: FloatSpacing.lg) {
            Spacer().frame(height: FloatSpacing.xl)
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
            Text("No results for \"\(viewModel.query)\"")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
            Text("Try different keywords or check spelling")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(FloatSpacing.md)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String, count: Int, icon: String, color: Color) -> some View {
        HStack(spacing: FloatSpacing.xs) {
            Image(systemName: icon).font(.caption).foregroundStyle(color)
            Text(title)
                .font(FloatFont.caption(.semibold))
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
            Text("(\(count))")
                .font(FloatFont.caption())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
        }
        .padding(.horizontal, FloatSpacing.md)
        .padding(.vertical, FloatSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FloatColors.adaptiveBackground)
    }
}

// MARK: - SearchDealRow

struct SearchDealRow: View {
    let deal: Deal

    var body: some View {
        HStack(spacing: FloatSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(deal.categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "tag.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(deal.categoryColor)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(deal.title)
                    .font(FloatFont.body(.semibold))
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    .lineLimit(1)
                HStack(spacing: FloatSpacing.xs) {
                    Text(deal.venueName ?? "Unknown")
                        .font(FloatFont.caption())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    Text("·")
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    Text(deal.discountDisplay)
                        .font(FloatFont.caption(.semibold))
                        .foregroundStyle(deal.categoryColor)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
        }
        .padding(.horizontal, FloatSpacing.md)
        .padding(.vertical, 10)
    }
}

// MARK: - SearchVenueRow

struct SearchVenueRow: View {
    let venue: Venue

    var body: some View {
        HStack(spacing: FloatSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(FloatColors.accent.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(FloatColors.accent)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(venue.name)
                    .font(FloatFont.body(.semibold))
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    .lineLimit(1)
                if let address = venue.address {
                    Text(address)
                        .font(FloatFont.caption())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
        }
        .padding(.horizontal, FloatSpacing.md)
        .padding(.vertical, 10)
    }
}

// MARK: - Mock Data

let mockVenues = [
    Venue(id: UUID(), name: "The Daily Brew", address: "123 Main St, Nashville",
          phone: "555-0100", website: "https://example.com",
          hours: "8am-10pm", isOpenNow: true, closingTime: "10:00 PM", isSaved: false),
    Venue(id: UUID(), name: "Food Court Pro", address: "456 Broadway, Nashville",
          phone: "555-0101", website: "https://example.com",
          hours: "11am-11pm", isOpenNow: true, closingTime: "11:00 PM", isSaved: true),
    Venue(id: UUID(), name: "Happy Hour Haven", address: "789 Commerce St, Nashville",
          phone: "555-0102", website: "https://example.com",
          hours: "4pm-12am", isOpenNow: true, closingTime: "12:00 AM", isSaved: false),
    Venue(id: UUID(), name: "The Mix", address: "321 5th Ave N, Nashville",
          phone: "555-0103", website: "https://example.com",
          hours: "5pm-2am", isOpenNow: false, closingTime: "2:00 AM", isSaved: false),
    Venue(id: UUID(), name: "Late Night Eats", address: "654 Church St, Nashville",
          phone: "555-0104", website: nil,
          hours: "10pm-4am", isOpenNow: true, closingTime: "4:00 AM", isSaved: true),
    Venue(id: UUID(), name: "Cocktail Corner", address: "987 Demonbreun St, Nashville",
          phone: "555-0105", website: "https://example.com",
          hours: "6pm-1am", isOpenNow: true, closingTime: "1:00 AM", isSaved: false)
]

let mockDeals = [
    Deal(id: UUID(), title: "2-for-1 Cocktails", description: "Buy one get one free on all cocktails",
         category: "drink", venueId: mockVenues[0].id, venueName: "The Daily Brew",
         expiresAt: Date().addingTimeInterval(3600), startsAt: Date(),
         discountType: "bogo", discountValue: nil, terms: "Valid at bar only.",
         distance: 300, distanceFromUser: 300),
    Deal(id: UUID(), title: "Happy Hour Nachos", description: "Half-price nachos all evening",
         category: "food", venueId: mockVenues[1].id, venueName: "Food Court Pro",
         expiresAt: Date().addingTimeInterval(7200), startsAt: Date(),
         discountType: "percentage", discountValue: 50, terms: "Dine-in only.",
         distance: 800, distanceFromUser: 800),
    Deal(id: UUID(), title: "30% Off Draft Beers", description: "All draft beers 30% off",
         category: "drink", venueId: mockVenues[2].id, venueName: "Happy Hour Haven",
         expiresAt: Date().addingTimeInterval(1800), startsAt: Date(),
         discountType: "percentage", discountValue: 30, terms: "21+ only.",
         distance: 500, distanceFromUser: 500),
    Deal(id: UUID(), title: "Burger & Beer Combo", description: "House burger + draft beer",
         category: "both", venueId: mockVenues[3].id, venueName: "The Mix",
         expiresAt: Date().addingTimeInterval(5400), startsAt: Date(),
         discountType: "fixed", discountValue: 5, terms: "One per customer.",
         distance: 1200, distanceFromUser: 1200),
    Deal(id: UUID(), title: "Flash: $3 Shots", description: "All well shots $3 — tonight only!",
         category: "flash", venueId: mockVenues[4].id, venueName: "Late Night Eats",
         expiresAt: Date().addingTimeInterval(900), startsAt: Date(),
         discountType: "fixed", discountValue: 3, terms: "While supplies last.",
         distance: 2000, distanceFromUser: 2000),
    Deal(id: UUID(), title: "Wine Wednesday 40% Off", description: "All bottles of wine 40% off",
         category: "drink", venueId: mockVenues[5].id, venueName: "Cocktail Corner",
         expiresAt: Date().addingTimeInterval(14400), startsAt: Date(),
         discountType: "percentage", discountValue: 40, terms: "Bottles only, no glass pours.",
         distance: 650, distanceFromUser: 650)
]
