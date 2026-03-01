import SwiftUI

struct DealCardView: View {
    let deal: Deal
    var heroImageURL: String? = nil
    @State private var isBookmarked = false

    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image thumbnail
                if let imageURL = heroImageURL, let url = URL(string: imageURL) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 120)
                                    .clipped()
                            case .empty:
                                Rectangle()
                                    .fill(FloatColors.cardBackground)
                                    .frame(height: 120)
                                    .overlay { ProgressView().tint(FloatColors.primary) }
                            default:
                                Rectangle()
                                    .fill(FloatColors.cardBackground)
                                    .frame(height: 120)
                            }
                        }

                        // Gradient overlay for text readability
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 60)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: FloatSpacing.cardRadius - 2))
                    .padding(.bottom, FloatSpacing.sm)
                }

            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                // Header with venue and distance
                HStack(alignment: .top, spacing: FloatSpacing.sm) {
                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        Text(deal.venueName ?? "Unknown Venue")
                            .font(FloatFont.caption(.semibold))
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                            .accessibilityHidden(true)

                        Text(deal.title)
                            .font(FloatFont.headline())
                            .lineLimit(2)
                            .accessibilityHidden(true)
                    }

                    Spacer()

                    // Distance badge
                    if let distance = deal.distanceFromUser {
                        Text(formatDistance(distance))
                            .font(FloatFont.caption(.semibold))
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                            .accessibilityLabel("\(formatDistance(distance))")
                    }
                }

                // Discount display
                HStack(spacing: FloatSpacing.md) {
                    FloatBadge(deal.discountDisplay, color: categoryColor)
                        .accessibilityHidden(true) // included in overall label below

                    Spacer()

                    // Expiry timer
                    HStack(spacing: FloatSpacing.xs) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .accessibilityHidden(true)
                        Text(deal.expiresAt?.timeRemainingShort ?? "No time")
                            .font(FloatFont.caption(.semibold))
                    }
                    .foregroundStyle(
                        deal.expiresAt?.isExpiringSoon ?? false
                            ? FloatColors.warning
                            : FloatColors.adaptiveTextSecondary
                    )
                    .accessibilityLabel(
                        deal.expiresAt?.isExpiringSoon ?? false
                            ? "Expiring soon: \(deal.expiresAt?.timeRemainingShort ?? "")"
                            : "Expires in \(deal.expiresAt?.timeRemainingShort ?? "unknown time")"
                    )
                }

                // Category icon + terms
                HStack(spacing: FloatSpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: categoryIcon)
                            .font(.system(size: 18))
                            .foregroundStyle(categoryColor)
                    }
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(deal.category.uppercased())
                            .font(FloatFont.caption2(.semibold))
                            .foregroundStyle(categoryColor)

                        if let terms = deal.terms {
                            Text(terms)
                                .font(FloatFont.caption2())
                                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                                .lineLimit(1)
                        }
                    }
                    .accessibilityHidden(true)

                    Spacer()

                    // Bookmark button
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                            isBookmarked.toggle()
                        }
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isBookmarked ? FloatColors.primary : FloatColors.adaptiveTextSecondary)
                            .bookmarkBounce(isBookmarked: isBookmarked)
                    }
                    .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark this deal")
                    .accessibilityAddTraits(isBookmarked ? [.isButton, .isSelected] : .isButton)
                }
            }
            }
        }
        .cardPressEffect()
        // Comprehensive VoiceOver description for the whole card
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Computed Helpers

    private var accessibilityDescription: String {
        var parts: [String] = []
        parts.append(deal.title)
        if let venue = deal.venueName { parts.append("at \(venue)") }
        parts.append(deal.discountDisplay)
        parts.append(deal.category)
        if let distance = deal.distanceFromUser { parts.append(formatDistance(distance)) }
        if let exp = deal.expiresAt?.timeRemainingShort { parts.append("expires in \(exp)") }
        return parts.joined(separator: ", ")
    }

    private var categoryColor: Color {
        switch deal.category.lowercased() {
        case "drink": return FloatColors.drinkColor
        case "food":  return FloatColors.foodColor
        case "both":  return FloatColors.comboColor
        case "flash": return FloatColors.eventColor
        default:      return FloatColors.primary
        }
    }

    private var categoryIcon: String {
        switch deal.category.lowercased() {
        case "drink": return "wineglass.fill"
        case "food":  return "fork.knife"
        case "both":  return "cart.fill"
        case "flash": return "bolt.fill"
        default:      return "tag.fill"
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m away"
        } else {
            return String(format: "%.1f km away", meters / 1000)
        }
    }
}
