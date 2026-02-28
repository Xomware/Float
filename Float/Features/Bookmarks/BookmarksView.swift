import SwiftUI

@MainActor
class BookmarksViewModel: ObservableObject {
    @Published var savedDeals: [Deal] = []
    @Published var savedVenues: [Venue] = []
    @Published var isLoading = false
    
    @ObservedObject var bookmarkService = BookmarkService.shared
    
    func loadBookmarks() async {
        isLoading = true
        
        // In production, fetch from Supabase filtered by saved IDs
        // For now, just populate with mock data filtered by bookmarks
        if !bookmarkService.savedDealIds.isEmpty {
            savedDeals = mockDeals.filter { bookmarkService.isDealSaved($0.id) }
        }
        
        if !bookmarkService.savedVenueIds.isEmpty {
            savedVenues = mockVenues.filter { bookmarkService.isVenueSaved($0.id) }
        }
        
        isLoading = false
    }
}

struct BookmarksView: View {
    @StateObject private var viewModel = BookmarksViewModel()
    @State private var selectedTab: BookmarkTab = .deals
    @ObservedObject var bookmarkService = BookmarkService.shared
    
    enum BookmarkTab {
        case deals
        case venues
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                FloatColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control
                    Picker("", selection: $selectedTab) {
                        Text("Saved Deals").tag(BookmarkTab.deals)
                        Text("Saved Venues").tag(BookmarkTab.venues)
                    }
                    .pickerStyle(.segmented)
                    .padding(FloatSpacing.md)
                    .background(FloatColors.cardBackground)
                    
                    Divider()
                        .background(FloatColors.textSecondary.opacity(0.2))
                    
                    // Content
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
            .task {
                await viewModel.loadBookmarks()
            }
            .refreshable {
                await viewModel.loadBookmarks()
            }
        }
    }
    
    @ViewBuilder
    private var dealsView: some View {
        if viewModel.savedDeals.isEmpty {
            VStack(spacing: FloatSpacing.lg) {
                Image(systemName: "bookmark")
                    .font(.system(size: 48))
                    .foregroundStyle(FloatColors.primary)
                
                Text("No Saved Deals")
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.textPrimary)
                
                Text("Explore deals and tap the bookmark icon to save your favorites")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.md)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            ScrollView {
                LazyVStack(spacing: FloatSpacing.md) {
                    ForEach(viewModel.savedDeals) { deal in
                        NavigationLink(destination: DealDetailView(deal: deal)) {
                            SavedDealCard(
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
            }
        }
    }
    
    @ViewBuilder
    private var venuesView: some View {
        if viewModel.savedVenues.isEmpty {
            VStack(spacing: FloatSpacing.lg) {
                Image(systemName: "location.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(FloatColors.primary)
                
                Text("No Saved Venues")
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.textPrimary)
                
                Text("Save your favorite venues to quickly access their deals")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.md)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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

struct SavedDealCard: View {
    let deal: Deal
    let onRemove: () -> Void
    
    @State private var showingRemoveConfirm = false
    
    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.md) {
                HStack(alignment: .top, spacing: FloatSpacing.md) {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        Text(deal.title)
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.textPrimary)
                        
                        if let venueName = deal.venueName {
                            Text(venueName)
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                        }
                        
                        if let description = deal.description {
                            Text(description)
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: FloatSpacing.sm) {
                        FloatBadge(text: deal.category.uppercased())
                        
                        if let expiresAt = deal.expiresAt {
                            Text(expiresAt.formatted(date: .abbreviated, time: .omitted))
                                .font(FloatFont.caption2())
                                .foregroundStyle(FloatColors.warning)
                        }
                    }
                }
                
                Divider()
                    .background(FloatColors.textSecondary.opacity(0.2))
                
                HStack(spacing: FloatSpacing.md) {
                    Button(action: { showingRemoveConfirm = true }) {
                        HStack(spacing: FloatSpacing.xs) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text("Remove")
                                .font(FloatFont.callout())
                        }
                        .foregroundStyle(FloatColors.error)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(FloatColors.primary)
                }
            }
        }
        .confirmationDialog(
            "Remove Bookmark?",
            isPresented: $showingRemoveConfirm,
            actions: {
                Button("Remove", role: .destructive) {
                    onRemove()
                }
            },
            message: {
                Text("Are you sure you want to remove this deal from your bookmarks?")
            }
        )
    }
}

struct SavedVenueCard: View {
    let venue: Venue
    let onRemove: () -> Void
    
    @State private var showingRemoveConfirm = false
    
    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.md) {
                HStack(alignment: .top, spacing: FloatSpacing.md) {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        Text(venue.name)
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.textPrimary)
                        
                        Text(venue.address)
                            .font(FloatFont.callout())
                            .foregroundStyle(FloatColors.textSecondary)
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
                        
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(FloatColors.primary)
                    }
                }
                
                Divider()
                    .background(FloatColors.textSecondary.opacity(0.2))
                
                Button(action: { showingRemoveConfirm = true }) {
                    HStack(spacing: FloatSpacing.xs) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                        Text("Remove")
                            .font(FloatFont.callout())
                    }
                    .foregroundStyle(FloatColors.error)
                }
            }
        }
        .confirmationDialog(
            "Remove Bookmark?",
            isPresented: $showingRemoveConfirm,
            actions: {
                Button("Remove", role: .destructive) {
                    onRemove()
                }
            },
            message: {
                Text("Are you sure you want to remove this venue from your bookmarks?")
            }
        )
    }
}

#Preview {
    BookmarksView()
        .environment(\.colorScheme, .dark)
}
