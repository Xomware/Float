import SwiftUI

/// Compact rating display for deal cards and detail views
struct RatingDisplayView: View {
    let averageRating: Double
    let reviewCount: Int

    var body: some View {
        if reviewCount > 0 {
            HStack(spacing: FloatSpacing.xs) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(FloatColors.warning)

                Text(String(format: "%.1f", averageRating))
                    .font(FloatFont.caption(.semibold))
                    .foregroundStyle(FloatColors.textPrimary)

                Text("(\(reviewCount))")
                    .font(FloatFont.caption2())
                    .foregroundStyle(FloatColors.textSecondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(String(format: "%.1f", averageRating)) stars from \(reviewCount) review\(reviewCount == 1 ? "" : "s")")
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RatingDisplayView(averageRating: 4.2, reviewCount: 47)
        RatingDisplayView(averageRating: 3.0, reviewCount: 1)
        RatingDisplayView(averageRating: 0, reviewCount: 0)
    }
    .padding()
    .background(FloatColors.background)
}
