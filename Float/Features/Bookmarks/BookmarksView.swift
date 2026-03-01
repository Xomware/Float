import SwiftUI

// MARK: - Bookmark Sort Options

enum BookmarkSortOption: String, CaseIterable {
    case dateSaved   = "Date Saved"
    case expiringSoon = "Expiring Soon"
    case category    = "Category"
    case discount    = "Discount"
}

// MARK: - BookmarksViewModel

@MainActor
class BookmarksViewModel: ObservableObject {
    @Published var savedDeals: [Deal] = []
    @Published var savedVenues: [Venue] = []
    @Published var isLoading = false
    @Published var sortOption: BookmarkSortOption = .dateSaved
    @Published var categoryFilter: DealCategory = .all

    @ObservedObject var bookmarkService = BookmarkService.shared

    var filteredDeals: [Deal] {
        var result = savedDeals

        if categoryFilter != .all {
            result = result.filter { deal in
                switch categoryFilter {
                case .all:    return true
                case .drinks: return deal.category.lowercased() == "drink"
                case .food:   return deal.category.lowercased() == "food"
                case .both:   return deal.category.lowercased() == "both"
                case .flash:  return deal.category.lowercased() == "flash"
                }
            }
        }

        switch sortOption {
        case .dateSaved:
            break
        case .expiringSoon:
            result.sort {
                ($0.expiresAt ?? Date.distantFuture) < ($1.expiresAt ?? Date.distantFuture)
            }
        case .category:
            result.sort { $0.category < $1.category }
        case .discount:
            result.sort { ($0.discountValue ?? 0) > ($1.discountValue ?? 0) }
        }

        return result
    }

    func loadBookmarks() async {
        isLoading = true
        defer { isLoading = false }

        if !bookmarkService.savedDealIds.isEmpty {
            savedDeals = mockDeals.filter { bookmarkService.isDealSaved($0.id) }
        } else {
            savedDeals = Array(mockDeals.prefix(3))
        }

        if !bookmarkService.savedVenueIds.isEmpty {
            savedVenues = mockVenues.filter { bookmarkService.isVenueSaved($0.id) }
        } else {
            savedVenues = Array(mockVenues.prefix(2))
        }
    }
}

// MARK: - BookmarksView

struct BookmarksView: View {
    @StateObject private var viewModel = BookmarksViewModel()
    @State private var selectedTab: BookmarkTab = .deals
    @ObservedObject var bookmarkService = BookmarkService.shared

    enum BookmarkTab {
        case deals, venues
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FloatColors.adaptiveBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Deals (\(viewModel.savedDeals.count))").tag(BookmarkTab.deals)
                        Text("Venues (\(viewModel.savedVenues.count))").tag(BookmarkTab.venues)
                    }
                    .pickerStyle(.segmented)
                    .padding(FloatSpacing.md)

                    if selectedTab == .deals && !viewModel.savedDeals.isEmpty {
                        dealControls
                    }

                    Divider().background(FloatColors.adaptiveSeparator)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(FloatColors.primary)
                            .frame(maxHeight: .infinity, alignment: .center)
                    } else if selectedTab == .deals {
                        dealsView
                    } else {
                        venuesView
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.loadBookmarks() }
            .refreshable { await viewModel.loadBookmarks() }
        }
    }

    // MARK: - Deal Controls

    private var dealControls: some View {
        VStack(spacing: FloatSpacing.xs) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: FloatSpacing.sm) {
                    ForEach(DealCategory.allCases, id: \.self) { cat in
                        FilterChip(
                            title: cat.rawValue,
                            isActive: viewModel.categoryFilter == cat,
                            action: { viewModel.categoryFilter = cat }
                        )
                    }
                }
                .padding(.horizontal, FloatSpacing.md)
            }

            HStack {
                Menu {
                    ForEach(BookmarkSortOption.allCases, id: \.self) { opt in
                        Button {
                            viewModel.sortOption = opt
                        } label: {
                            HStack {
                                Text(opt.rawValue)
                                if viewModel.sortOption == opt {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: FloatSpacing.xs) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort: \(viewModel.sortOption.rawValue)")
                    }
                    .font(FloatFont.caption(.semibold))
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                }
                Spacer()
                Text("\(viewModel.filteredDeals.count) saved")
                    .font(FloatFont.caption())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
            }
            .padding(.horizontal, FloatSpacing.md)
            .padding(.bottom, FloatSpacing.sm)
        }
        .background(FloatColors.adaptiveBackground)
    }

    // MARK: - Deals View

    @ViewBuilder
    private var dealsView: some View {
        if viewModel.filteredDeals.isEmpty {
            VStack(spacing: FloatSpacing.lg) {
                Spacer()
                Image(systemName: "bookmark")
                    .font(.system(size: 52))
                    .foregroundStyle(FloatColors.primary.opacity(0.6))
                Text(viewModel.savedDeals.isEmpty ? "No Saved Deals" : "No Matches")
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                Text(viewModel.savedDeals.isEmpty
                     ? "Tap the bookmark icon on any deal to save it"
                     : "Try a different category filter")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.xl)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: FloatSpacing.md) {
                    ForEach(viewModel.filteredDeals) { deal in
                        NavigationLink(destination: DealDetailView(deal: deal)) {
                            EnhancedSavedDealCard(
                                deal: deal,
                                onRemove: {
                                    Task {
                                        await bookmarkService.unsaveDeal(deal.id)
                                        await viewModel.loadBookmarks()
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(FloatSpacing.md)
                .animation(.easeInOut(duration: 0.25), value: viewModel.filteredDeals.count)
            }
        }
    }

    // MARK: - Venues View

    @ViewBuilder
    private var venuesView: some View {
        if viewModel.savedVenues.isEmpty {
            VStack(spacing: FloatSpacing.lg) {
                Spacer()
                Image(systemName: "location.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(FloatColors.primary.opacity(0.6))
                Text("No Saved Venues")
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                Text("Save your favorite venues to get notified of new deals")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.xl)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: FloatSpacing.md) {
                    ForEach(viewModel.savedVenues) { venue in
                        SavedVenueCard(
                            venue: venue,
                            onRemove: {
                                Task {
                                    await bookmarkService.unsaveVenue(venue.id)
                                    await viewModel.loadBookmarks()
                                }
                            }
                        )
                    }
                }
                .padding(FloatSpacing.md)
            }
        }
    }
}

// MARK: - EnhancedSavedDealCard

struct EnhancedSavedDealCard: View {
    let deal: Deal
    let onRemove: () -> Void

    @State private var showingRemoveConfirm = false
    @State private var showShareSheet = false

    private var isExpiringSoon: Bool {
        guard let expiresAt = deal.expiresAt else { return false }
        return expiresAt.timeIntervalSinceNow < 7200
    }

    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.md) {
                HStack(alignment: .top, spacing: FloatSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(deal.categoryColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "tag.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(deal.categoryColor)
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        HStack(spacing: FloatSpacing.xs) {
                            Text(deal.title)
                                .font(FloatFont.headline())
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                                .lineLimit(1)
                            if isExpiringSoon {
                                Text("SOON")
                                    .font(.system(size: 8, weight: .bold))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(FloatColors.warning)
                                    .foregroundStyle(.white)
                                    .cornerRadius(4)
                            }
                        }

                        if let venueName = deal.venueName {
                            Text(venueName)
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        }

                        HStack(spacing: FloatSpacing.sm) {
                            Text(deal.discountDisplay)
                                .font(FloatFont.caption(.semibold))
                                .foregroundStyle(deal.categoryColor)

                            if let expiresAt = deal.expiresAt {
                                Text("·").foregroundStyle(FloatColors.adaptiveTextSecondary)
                                HStack(spacing: 2) {
                                    Image(systemName: "clock").font(.caption2)
                                    Text(expiresAt, style: .relative)
                                }
                                .font(FloatFont.caption())
                                .foregroundStyle(isExpiringSoon ? FloatColors.warning : FloatColors.adaptiveTextSecondary)
                            }
                        }
                    }
                }

                Divider().background(FloatColors.adaptiveSeparator)

                HStack(spacing: FloatSpacing.lg) {
                    Button {
                        showShareSheet = true
                    } label: {
                        HStack(spacing: FloatSpacing.xs) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 13))
                            Text("Share")
                        }
                        .font(FloatFont.caption(.semibold))
                        .foregroundStyle(FloatColors.primary)
                    }
                    .accessibilityLabel("Share \(deal.title)")

                    Spacer()

                    Button { showingRemoveConfirm = true } label: {
                        HStack(spacing: FloatSpacing.xs) {
                            Image(systemName: "bookmark.slash").font(.system(size: 13))
                            Text("Remove")
                        }
                        .font(FloatFont.caption(.semibold))
                        .foregroundStyle(FloatColors.error)
                    }
                    .accessibilityLabel("Remove \(deal.title) bookmark")
                }
            }
        }
        .confirmationDialog("Remove Bookmark?", isPresented: $showingRemoveConfirm) {
            Button("Remove", role: .destructive) { onRemove() }
        } message: {
            Text("Remove \"\(deal.title)\" from saved deals?")
        }
        .contextMenu {
            Button { } label: {
                Label("View Venue", systemImage: "building.2.fill")
            }
            Button { showShareSheet = true } label: {
                Label("Share Deal", systemImage: "square.and.arrow.up")
            }
            Button(role: .destructive) { showingRemoveConfirm = true } label: {
                Label("Remove Bookmark", systemImage: "bookmark.slash")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["\(deal.title) — \(deal.discountDisplay) at \(deal.venueName ?? "Unknown")"])
                .presentationDetents([.medium])
        }
    }
}

// MARK: - SavedVenueCard

struct SavedVenueCard: View {
    let venue: Venue
    let onRemove: () -> Void

    @State private var showingRemoveConfirm = false

    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.md) {
                HStack(alignment: .top, spacing: FloatSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(FloatColors.accent.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(FloatColors.accent)
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        Text(venue.name)
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.adaptiveTextPrimary)
                        if let address = venue.address {
                            Text(address)
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                                .lineLimit(1)
                        }
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill").font(.caption2).foregroundStyle(FloatColors.warning)
                            Text(String(format: "%.1f", venue.rating))
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                        }
                    }

                    Spacer()
                    Image(systemName: "bookmark.fill").foregroundStyle(FloatColors.primary)
                }

                Divider().background(FloatColors.adaptiveSeparator)

                Button { showingRemoveConfirm = true } label: {
                    HStack(spacing: FloatSpacing.xs) {
                        Image(systemName: "bookmark.slash").font(.system(size: 13))
                        Text("Remove")
                    }
                    .font(FloatFont.caption(.semibold))
                    .foregroundStyle(FloatColors.error)
                }
            }
        }
        .confirmationDialog("Remove Venue?", isPresented: $showingRemoveConfirm) {
            Button("Remove", role: .destructive) { onRemove() }
        } message: {
            Text("Remove \"\(venue.name)\" from saved venues?")
        }
    }
}

#Preview {
    BookmarksView()
        .environment(\.colorScheme, .dark)
}
