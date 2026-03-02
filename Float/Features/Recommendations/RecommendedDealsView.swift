import SwiftUI

struct RecommendedDealsView: View {
    @StateObject private var viewModel = RecommendationViewModel()
    let deals: [Deal]

    var body: some View {
        Group {
            if viewModel.isLoading {
                // Skeleton placeholder
                recommendationSkeleton
            } else if !viewModel.hasHistory {
                // Empty state — user has no redemption history yet
                emptyState
            } else if !viewModel.recommendations.isEmpty {
                // Carousel
                recommendationCarousel
            }
        }
        .task {
            await viewModel.loadRecommendations(deals: deals)
        }
    }

    // MARK: - Carousel

    private var recommendationCarousel: some View {
        VStack(alignment: .leading, spacing: FloatSpacing.sm) {
            // Header
            HStack {
                Text("✨ For You")
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)

                Spacer()

                Button {
                    Task { await viewModel.loadRecommendations(deals: deals) }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FloatColors.primary)
                }
                .accessibilityLabel("Refresh recommendations")
            }
            .padding(.horizontal, FloatSpacing.md)

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: FloatSpacing.sm) {
                    ForEach(viewModel.recommendations, id: \.deal.id) { scored in
                        NavigationLink(destination: DealDetailView(deal: scored.deal)) {
                            RecommendedDealCard(scoredDeal: scored)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, FloatSpacing.md)
            }
        }
        .padding(.vertical, FloatSpacing.sm)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: FloatSpacing.sm) {
            Text("✨ For You")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, FloatSpacing.md)

            FloatCard {
                VStack(spacing: FloatSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundStyle(FloatColors.primary.opacity(0.6))

                    Text("Redeem a few deals to get personalized picks!")
                        .font(FloatFont.callout())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(FloatSpacing.lg)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, FloatSpacing.md)
        }
        .padding(.vertical, FloatSpacing.sm)
    }

    // MARK: - Skeleton

    private var recommendationSkeleton: some View {
        VStack(alignment: .leading, spacing: FloatSpacing.sm) {
            Text("✨ For You")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                .padding(.horizontal, FloatSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: FloatSpacing.sm) {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonView()
                            .frame(width: 240, height: 160)
                            .cornerRadius(FloatSpacing.cardRadius)
                    }
                }
                .padding(.horizontal, FloatSpacing.md)
            }
        }
        .padding(.vertical, FloatSpacing.sm)
    }
}

// MARK: - Recommended Deal Card

struct RecommendedDealCard: View {
    let scoredDeal: RecommendationEngine.ScoredDeal

    private var deal: Deal { scoredDeal.deal }

    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                // Venue + category
                HStack {
                    Text(deal.venueName ?? "Unknown Venue")
                        .font(FloatFont.caption(.semibold))
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)

                    Spacer()

                    FloatBadge(deal.category.uppercased(), color: deal.categoryColor)
                }

                // Title
                Text(deal.title)
                    .font(FloatFont.headline())
                    .lineLimit(2)

                // Discount
                Text(deal.discountDisplay)
                    .font(FloatFont.callout(.semibold))
                    .foregroundStyle(deal.categoryColor)

                // Expiry
                if let expiresAt = deal.expiresAt {
                    HStack(spacing: FloatSpacing.xs) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text(expiresAt.timeRemainingShort)
                            .font(FloatFont.caption2())
                    }
                    .foregroundStyle(
                        expiresAt.isExpiringSoon
                            ? FloatColors.warning
                            : FloatColors.adaptiveTextSecondary
                    )
                }

                // Explanation badge
                Text(scoredDeal.explanation)
                    .font(FloatFont.caption2(.semibold))
                    .foregroundStyle(FloatColors.primary)
                    .padding(.horizontal, FloatSpacing.sm)
                    .padding(.vertical, 4)
                    .background(FloatColors.primary.opacity(0.1))
                    .cornerRadius(FloatSpacing.badgeRadius)
                    .lineLimit(1)
            }
            .frame(width: 220)
        }
        .cardPressEffect()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(deal.title) at \(deal.venueName ?? "unknown venue"), \(deal.discountDisplay). \(scoredDeal.explanation)")
    }
}
