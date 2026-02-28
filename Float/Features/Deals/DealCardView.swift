import SwiftUI

struct DealCardView: View {
    let deal: Deal
    
    var body: some View {
        FloatCard {
            VStack(alignment: .leading, spacing: FloatSpacing.sm) {
                // Header with venue and distance
                HStack(alignment: .top, spacing: FloatSpacing.sm) {
                    VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                        Text(deal.venueName ?? "Unknown Venue")
                            .font(FloatFont.caption(.semibold))
                            .foregroundStyle(FloatColors.textSecondary)
                        
                        Text(deal.title)
                            .font(FloatFont.headline())
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Distance badge
                    if let distance = deal.distanceFromUser {
                        Text(formatDistance(distance))
                            .font(FloatFont.caption(.semibold))
                            .foregroundStyle(FloatColors.textSecondary)
                    }
                }
                
                // Discount display
                HStack(spacing: FloatSpacing.md) {
                    // Discount badge
                    FloatBadge(deal.discountDisplay, color: categoryColor)
                    
                    Spacer()
                    
                    // Timer
                    HStack(spacing: FloatSpacing.xs) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                        Text(deal.expiresAt?.timeRemainingShort ?? "No time")
                            .font(FloatFont.caption(.semibold))
                    }
                    .foregroundStyle(deal.expiresAt?.isExpiringSoon ?? false ? FloatColors.warning : FloatColors.textSecondary)
                }
                
                // Category and detail
                HStack(spacing: FloatSpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: categoryIcon)
                            .font(.system(size: 18))
                            .foregroundStyle(categoryColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(deal.category.uppercased())
                            .font(FloatFont.caption2(.semibold))
                            .foregroundStyle(categoryColor)
                        
                        if let terms = deal.terms {
                            Text(terms)
                                .font(FloatFont.caption2())
                                .foregroundStyle(FloatColors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
            }
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
    
    private var categoryIcon: String {
        switch deal.category.lowercased() {
        case "drink": return "wineglass.fill"
        case "food": return "fork.knife"
        case "both": return "cart.fill"
        case "flash": return "bolt.fill"
        default: return "tag.fill"
        }
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m away"
        } else {
            let km = meters / 1000
            return String(format: "%.1f km away", km)
        }
    }
}
