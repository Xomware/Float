// OfflineBannerView.swift
// Float

import SwiftUI

struct OfflineBannerView: View {
    @State private var isDismissed = false
    var cacheDate: Date?

    var body: some View {
        if !isDismissed {
            HStack(spacing: FloatSpacing.sm) {
                Text("📵")
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text("You're offline — showing cached deals")
                        .font(FloatFont.caption(.semibold))
                        .foregroundStyle(.white)

                    if let cacheDate {
                        Text("Last updated \(cacheDate.relativeDescription)")
                            .font(FloatFont.caption2())
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isDismissed = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.8))
                }
                .accessibilityLabel("Dismiss offline banner")
            }
            .padding(.horizontal, FloatSpacing.md)
            .padding(.vertical, FloatSpacing.sm)
            .background(Color.orange.gradient)
            .cornerRadius(FloatSpacing.badgeRadius)
            .padding(.horizontal, FloatSpacing.md)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Date helper for cache age display
extension Date {
    var relativeDescription: String {
        let interval = Date().timeIntervalSince(self)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "just now" }
        if minutes < 60 { return "\(minutes) minute\(minutes == 1 ? "" : "s") ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours) hour\(hours == 1 ? "" : "s") ago" }
        let days = hours / 24
        return "\(days) day\(days == 1 ? "" : "s") ago"
    }
}
