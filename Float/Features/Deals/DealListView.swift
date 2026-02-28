import SwiftUI

struct DealListView: View {
    @StateObject private var viewModel = DealViewModel()
    @State private var showSortMenu = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with deal count
                VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                    HStack(alignment: .center, spacing: FloatSpacing.sm) {
                        Text("\(viewModel.filteredDeals.count) deals near you")
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.textPrimary)
                        
                        Spacer()
                        
                        // Sort picker
                        Menu {
                            ForEach(DealSortOption.allCases, id: \.self) { option in
                                Button(action: { viewModel.updateSort(option) }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if viewModel.sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: FloatSpacing.xs) {
                                Image(systemName: "arrow.up.arrow.down")
                                Text("Sort")
                            }
                            .font(FloatFont.caption(.semibold))
                            .padding(.horizontal, FloatSpacing.sm)
                            .padding(.vertical, 6)
                            .background(FloatColors.cardBackground)
                            .cornerRadius(FloatSpacing.badgeRadius)
                        }
                    }
                    .padding(FloatSpacing.md)
                }
                .background(FloatColors.background)
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: FloatSpacing.sm) {
                        ForEach(DealCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.rawValue,
                                isActive: viewModel.activeFilter == category,
                                action: { viewModel.updateFilter(category) }
                            )
                        }
                    }
                    .padding(.horizontal, FloatSpacing.md)
                    .padding(.vertical, FloatSpacing.sm)
                }
                .background(FloatColors.background)
                
                // Deals list
                ZStack {
                    FloatColors.background.ignoresSafeArea()
                    
                    if viewModel.filteredDeals.isEmpty {
                        EmptyDealsView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: FloatSpacing.sm) {
                                ForEach(viewModel.filteredDeals) { deal in
                                    NavigationLink(destination: DealDetailView(deal: deal)) {
                                        DealCardView(deal: deal)
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        // Infinite scroll: load more when near the end
                                        if deal.id == viewModel.filteredDeals.last?.id && viewModel.hasMore {
                                            Task { await viewModel.loadMoreDeals() }
                                        }
                                    }
                                }
                            }
                            .padding(FloatSpacing.md)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Active Deals")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await viewModel.loadDeals() }
        }
        .task { await viewModel.loadDeals() }
    }
}

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FloatFont.caption(.semibold))
                .padding(.horizontal, FloatSpacing.sm)
                .padding(.vertical, 6)
                .background(isActive ? FloatColors.primary : FloatColors.cardBackground)
                .foregroundStyle(isActive ? .white : FloatColors.textPrimary)
                .cornerRadius(FloatSpacing.badgeRadius)
        }
    }
}

struct EmptyDealsView: View {
    var body: some View {
        VStack(spacing: FloatSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(FloatColors.textSecondary.opacity(0.5))
            
            Text("No deals found")
                .font(FloatFont.headline())
            
            Text("Try adjusting your filters or sort options")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding(FloatSpacing.lg)
    }
}

struct DealDetailView: View {
    let deal: Deal
    @State private var isSaved = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FloatSpacing.lg) {
                // Header section
                VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                    Text(deal.title)
                        .font(FloatFont.title())
                    
                    Text(deal.venueName ?? "Unknown Venue")
                        .font(FloatFont.callout())
                        .foregroundStyle(FloatColors.textSecondary)
                }
                
                // Discount display (big)
                FloatCard {
                    VStack(spacing: FloatSpacing.md) {
                        Text("YOUR DISCOUNT")
                            .font(FloatFont.caption2(.semibold))
                            .foregroundStyle(FloatColors.textSecondary)
                        
                        Text(deal.discountDisplay)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(deal.categoryColor)
                        
                        FloatBadge(deal.category.uppercased(), color: deal.categoryColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(FloatSpacing.lg)
                }
                
                // Timer
                VStack(spacing: FloatSpacing.sm) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(FloatColors.warning)
                        Text("Expires in \(deal.expiresAt?.timeRemainingShort ?? "Unknown")")
                            .font(FloatFont.headline())
                    }
                    
                    if let startsAt = deal.startsAt, startsAt > Date() {
                        Text("Available in \(startsAt.timeRemainingShort)")
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.textSecondary)
                    }
                }
                .padding(FloatSpacing.md)
                .background(FloatColors.cardBackground)
                .cornerRadius(FloatSpacing.cardRadius)
                
                // Description
                if let description = deal.description {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        Text("About")
                            .font(FloatFont.headline())
                        
                        Text(description)
                            .font(FloatFont.body())
                            .foregroundStyle(FloatColors.textSecondary)
                    }
                }
                
                // Terms
                if let terms = deal.terms {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        Text("Terms & Conditions")
                            .font(FloatFont.headline())
                        
                        Text(terms)
                            .font(FloatFont.callout())
                            .foregroundStyle(FloatColors.textSecondary)
                    }
                }
                
                // Venue card
                VStack(alignment: .leading, spacing: FloatSpacing.md) {
                    Text("Venue")
                        .font(FloatFont.headline())
                    
                    NavigationLink(destination: VenueProfileView(venueId: deal.venueId, venueName: deal.venueName ?? "Unknown")) {
                        FloatCard {
                            HStack(spacing: FloatSpacing.md) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(deal.categoryColor.opacity(0.15))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "building.2.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(deal.categoryColor)
                                }
                                
                                VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                                    Text(deal.venueName ?? "Unknown")
                                        .font(FloatFont.headline())
                                    
                                    Text("View full profile")
                                        .font(FloatFont.caption())
                                        .foregroundStyle(FloatColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(FloatColors.textSecondary)
                            }
                        }
                    }
                }
                
                Spacer()
                    .frame(height: FloatSpacing.lg)
            }
            .padding(FloatSpacing.md)
        }
        .floatScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isSaved.toggle() }) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? FloatColors.error : FloatColors.textPrimary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            FloatButton("Get This Deal", icon: "sparkles", style: .primary) {
                // Handle get deal action
            }
            .padding(FloatSpacing.md)
        }
    }
    
    private var categoryColor: Color {
        switch deal.category.lowercased() {
        case "drink": return FloatColors.drinkColor
        case "food": return FloatColors.foodColor
        case "both": return FloatColors.comboColor
        case "flash": return FloatColors.eventColor
        default: return FloatColors.primary
        }
    }
}

struct SearchView: View {
    @State private var query = ""
    var body: some View {
        NavigationStack {
            Text("Search coming soon").foregroundStyle(FloatColors.textSecondary)
                .floatScreenBackground()
                .navigationTitle("Search")
                .searchable(text: $query)
        }
    }
}
