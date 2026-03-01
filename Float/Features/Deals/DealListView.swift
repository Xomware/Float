// DealListView.swift
// Float

import SwiftUI

struct DealListView: View {
    @StateObject private var viewModel = DealViewModel()
    @StateObject private var searchService = SearchService()
    @State private var searchFilter = SearchFilter()
    @State private var showFilters = false
    @State private var showSavedFilters = false

    /// Deals to display: use search results when a filter is active, otherwise the VM's filtered list.
    private var displayedDeals: [Deal] {
        searchFilter.isDefault && searchFilter.query.isEmpty
            ? viewModel.filteredDeals
            : searchService.results
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBarView(text: $searchFilter.query, placeholder: "Search deals…")
                    .onChange(of: searchFilter.query) { _ in
                        triggerSearch()
                    }

                // Header with deal count + filter button
                VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                    HStack(alignment: .center, spacing: FloatSpacing.sm) {
                        Text(viewModel.isLoading ? "Finding deals…" : "\(displayedDeals.count) deals near you")
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.adaptiveTextPrimary)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: displayedDeals.count)

                        Spacer()

                        // Saved filters
                        Button { showSavedFilters = true } label: {
                            Image(systemName: "bookmark")
                                .font(FloatFont.caption(.semibold))
                                .padding(.horizontal, FloatSpacing.sm)
                                .padding(.vertical, 6)
                                .background(FloatColors.adaptiveCardBackground)
                                .cornerRadius(FloatSpacing.badgeRadius)
                        }
                        .accessibilityLabel("Saved filters")
                        .sheet(isPresented: $showSavedFilters) {
                            SavedFiltersView(currentFilter: $searchFilter)
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
                        }

                        // Filter button
                        Button { showFilters = true } label: {
                            HStack(spacing: FloatSpacing.xs) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Filters")
                                if searchFilter.activeFilterCount > 0 {
                                    Text("\(searchFilter.activeFilterCount)")
                                        .font(.caption2.bold())
                                        .padding(4)
                                        .background(FloatColors.primary)
                                        .foregroundStyle(.white)
                                        .clipShape(Circle())
                                }
                            }
                            .font(FloatFont.caption(.semibold))
                            .padding(.horizontal, FloatSpacing.sm)
                            .padding(.vertical, 6)
                            .background(searchFilter.activeFilterCount > 0
                                ? FloatColors.primary.opacity(0.15)
                                : FloatColors.adaptiveCardBackground)
                            .foregroundStyle(searchFilter.activeFilterCount > 0
                                ? FloatColors.primary
                                : FloatColors.adaptiveTextPrimary)
                            .cornerRadius(FloatSpacing.badgeRadius)
                        }
                        .accessibilityLabel("Filter deals")
                        .sheet(isPresented: $showFilters) {
                            SearchFilterView(filter: $searchFilter)
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
                        }
                    }
                    .padding(FloatSpacing.md)
                }
                .background(FloatColors.adaptiveBackground)
                .onChange(of: searchFilter) { _ in triggerSearch() }

                // Active filter chips
                ActiveFiltersView(filter: $searchFilter)

                // Category quick-filter chips
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
                .background(FloatColors.adaptiveBackground)

                // Error banner (non-blocking inline)
                if let errorMsg = viewModel.errorMessage, !viewModel.isLoading {
                    ErrorBannerView(message: errorMsg) {
                        viewModel.errorMessage = nil
                    }
                    .padding(.horizontal, FloatSpacing.md)
                    .transition(.floatSlideUp)
                }

                // Main content
                ZStack {
                    FloatColors.adaptiveBackground.ignoresSafeArea()

                    if viewModel.isLoading && viewModel.filteredDeals.isEmpty {
                        // Skeleton loading
                        DealListSkeletonView(count: 4)
                            .transition(.floatFade)
                    } else if let error = viewModel.loadError, viewModel.filteredDeals.isEmpty {
                        // Full-screen error state
                        ErrorStateView.loadError(what: "deals") {
                            Task { await viewModel.loadDeals() }
                        }
                        .transition(.floatFade)
                    } else if displayedDeals.isEmpty {
                        // Empty state
                        EmptyStateView(
                            EmptyStateConfig.noDealsNearby {
                                viewModel.updateFilter(nil)
                            }
                        )
                        .transition(.floatFade)
                    } else {
                        // Deal list with animated cards
                        ScrollView {
                            LazyVStack(spacing: FloatSpacing.sm) {
                                ForEach(Array(displayedDeals.enumerated()), id: \.element.id) { index, deal in
                                    NavigationLink(destination: DealDetailView(deal: deal)) {
                                        AnimatedDealCard(index: index) {
                                            DealCardView(deal: deal)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .onAppear {
                                        if deal.id == displayedDeals.last?.id && viewModel.hasMore {
                                            Task { await viewModel.loadMoreDeals() }
                                        }
                                    }
                                }

                                // Load-more spinner
                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .padding(.vertical, FloatSpacing.md)
                                        .accessibilityLabel("Loading more deals")
                                }
                            }
                            .padding(FloatSpacing.md)
                        }
                        .transition(.floatFade)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                .animation(.easeInOut(duration: 0.25), value: displayedDeals.isEmpty)

                Spacer()
            }
            .navigationTitle("Active Deals")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await viewModel.loadDeals() }
        }
        .task { await viewModel.loadDeals() }
    }

    private func triggerSearch() {
        searchService.debouncedSearch(deals: viewModel.deals, filter: searchFilter)
    }
}

// MARK: - Filter Chip
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
                .background(isActive ? FloatColors.primary : FloatColors.adaptiveCardBackground)
                .foregroundStyle(isActive ? .white : FloatColors.adaptiveTextPrimary)
                .cornerRadius(FloatSpacing.badgeRadius)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
        .accessibilityLabel("\(title) filter")
        .accessibilityAddTraits(isActive ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Deal Detail View
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
                        .accessibilityAddTraits(.isHeader)

                    Text(deal.venueName ?? "Unknown Venue")
                        .font(FloatFont.callout())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                }

                // Discount display (big)
                FloatCard {
                    VStack(spacing: FloatSpacing.md) {
                        Text("YOUR DISCOUNT")
                            .font(FloatFont.caption2(.semibold))
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)

                        Text(deal.discountDisplay)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(deal.categoryColor)
                            .accessibilityLabel("Discount: \(deal.discountDisplay)")

                        FloatBadge(deal.category.uppercased(), color: deal.categoryColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(FloatSpacing.lg)
                }
                .slideIn()

                // Timer
                VStack(spacing: FloatSpacing.sm) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(FloatColors.warning)
                            .accessibilityHidden(true)
                        Text("Expires in \(deal.expiresAt?.timeRemainingShort ?? "Unknown")")
                            .font(FloatFont.headline())
                    }

                    if let startsAt = deal.startsAt, startsAt > Date() {
                        Text("Available in \(startsAt.timeRemainingShort)")
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }
                }
                .padding(FloatSpacing.md)
                .background(FloatColors.adaptiveCardBackground)
                .cornerRadius(FloatSpacing.cardRadius)
                .accessibilityElement(children: .combine)

                // Description
                if let description = deal.description {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        Text("About")
                            .font(FloatFont.headline())
                            .accessibilityAddTraits(.isHeader)
                        Text(description)
                            .font(FloatFont.body())
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }
                }

                // Terms
                if let terms = deal.terms {
                    VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                        Text("Terms & Conditions")
                            .font(FloatFont.headline())
                            .accessibilityAddTraits(.isHeader)
                        Text(terms)
                            .font(FloatFont.callout())
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }
                }

                // Venue card
                VStack(alignment: .leading, spacing: FloatSpacing.md) {
                    Text("Venue")
                        .font(FloatFont.headline())
                        .accessibilityAddTraits(.isHeader)

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
                                .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                                    Text(deal.venueName ?? "Unknown")
                                        .font(FloatFont.headline())
                                    Text("View full profile")
                                        .font(FloatFont.caption())
                                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .accessibilityLabel("View \(deal.venueName ?? "venue") profile")
                }

                Spacer().frame(height: FloatSpacing.lg)
            }
            .padding(FloatSpacing.md)
        }
        .floatScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) { isSaved.toggle() }
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? FloatColors.error : FloatColors.adaptiveTextPrimary)
                        .bookmarkBounce(isBookmarked: isSaved)
                }
                .accessibilityLabel(isSaved ? "Remove from saved" : "Save deal")
            }
        }
        .safeAreaInset(edge: .bottom) {
            FloatButton("Get This Deal", icon: "sparkles", style: .primary) {
                // Handle get deal action
            }
            .padding(FloatSpacing.md)
        }
    }
}
