// ClusteredDealsBottomSheet.swift
// Float

import SwiftUI
import CoreLocation

struct ClusteredDealsBottomSheet: View {
    let deals: [DealPin]
    let userLocation: CLLocationCoordinate2D?
    let onDismiss: () -> Void
    let onSelectDeal: (DealPin) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(FloatColors.textSecondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, FloatSpacing.sm)
                    .padding(.bottom, FloatSpacing.xs)

                // Header
                HStack {
                    Text("\(deals.count) Deals Nearby")
                        .font(FloatFont.headline())
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(FloatColors.textSecondary)
                            .font(.title3)
                    }
                }
                .padding(.horizontal, FloatSpacing.md)
                .padding(.bottom, FloatSpacing.sm)

                // Deal list
                ScrollView {
                    LazyVStack(spacing: FloatSpacing.sm) {
                        ForEach(deals) { pin in
                            ClusteredDealCard(pin: pin, userLocation: userLocation)
                                .onTapGesture { onSelectDeal(pin) }
                        }
                    }
                    .padding(.horizontal, FloatSpacing.md)
                    .padding(.bottom, FloatSpacing.lg)
                }
                .frame(maxHeight: 320)
            }
            .background(FloatColors.cardBackground)
            .cornerRadius(FloatSpacing.cardRadius, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ClusteredDealCard: View {
    let pin: DealPin
    let userLocation: CLLocationCoordinate2D?

    var body: some View {
        FloatCard {
            HStack(spacing: FloatSpacing.sm) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(pin.categoryColor)
                        .frame(width: 40, height: 40)
                    Image(systemName: categoryIcon)
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(pin.venueName)
                        .font(FloatFont.body(.semibold))
                        .lineLimit(1)
                    Text(pin.deal.discountDisplay)
                        .font(FloatFont.caption(.semibold))
                        .foregroundStyle(FloatColors.accent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formattedDistance)
                        .font(FloatFont.caption(.regular))
                        .foregroundStyle(FloatColors.textSecondary)
                    Text(pin.expiresAt.timeRemainingShort)
                        .font(FloatFont.caption(.regular))
                        .foregroundStyle(pin.expiresAt.isExpiringSoon ? FloatColors.warning : FloatColors.textSecondary)
                }
            }
        }
    }

    private var categoryIcon: String {
        switch pin.category.lowercased() {
        case "drink": return "wineglass.fill"
        case "food": return "fork.knife"
        case "both": return "cart.fill"
        case "flash": return "bolt.fill"
        default: return "tag.fill"
        }
    }

    var formattedDistance: String {
        guard let userLoc = userLocation else { return "" }
        let pinLoc = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
        let userCLLoc = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let meters = pinLoc.distance(from: userCLLoc)
        return Self.formatDistance(meters: meters)
    }

    /// Format a distance in meters to a human-readable string.
    static func formatDistance(meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            let miles = meters / 1609.34
            return String(format: "%.1fmi", miles)
        }
    }
}

// MARK: - Corner Radius Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
