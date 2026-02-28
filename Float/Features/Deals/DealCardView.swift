import SwiftUI

struct DealCardView: View {
    let deal: Deal
    
    var body: some View {
        FloatCard {
            HStack(spacing: FloatSpacing.md) {
                // Category icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: categoryIcon)
                        .font(.system(size: 22))
                        .foregroundStyle(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                    Text(deal.title).font(FloatFont.headline()).lineLimit(1)
                    Text(deal.venueName ?? "").font(FloatFont.callout()).foregroundStyle(FloatColors.textSecondary)
                    HStack {
                        FloatBadge(deal.category.uppercased(), color: categoryColor)
                        Spacer()
                        if let expires = deal.expiresAt {
                            Text(expires.timeRemainingShort)
                                .font(FloatFont.caption())
                                .foregroundStyle(expires.isExpiringSoon ? FloatColors.warning : FloatColors.textSecondary)
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    private var categoryColor: Color {
        switch deal.category {
        case "drink": return FloatColors.drinkColor
        case "food": return FloatColors.foodColor
        case "combo": return FloatColors.comboColor
        case "event": return FloatColors.eventColor
        default: return FloatColors.primary
        }
    }
    
    private var categoryIcon: String {
        switch deal.category {
        case "drink": return "wineglass.fill"
        case "food": return "fork.knife"
        case "combo": return "cart.fill"
        case "event": return "music.note"
        default: return "tag.fill"
        }
    }
}
