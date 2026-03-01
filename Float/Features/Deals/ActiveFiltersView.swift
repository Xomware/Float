// ActiveFiltersView.swift
// Float

import SwiftUI

struct ActiveFiltersView: View {
    @Binding var filter: SearchFilter

    var body: some View {
        if !filter.isDefault && filter.activeFilterCount > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: FloatSpacing.sm) {
                    // Category chips
                    if !filter.categories.isEmpty {
                        ForEach(Array(filter.categories).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { cat in
                            activeChip(cat.rawValue) {
                                filter.categories.remove(cat)
                            }
                        }
                    }

                    // Distance chip
                    if let dist = filter.maxDistance {
                        activeChip("≤ \(String(format: "%.1f", dist)) mi") {
                            filter.maxDistance = nil
                        }
                    }

                    // Discount chip
                    if let disc = filter.minDiscount, disc > 0 {
                        activeChip("≥ \(disc)% off") {
                            filter.minDiscount = nil
                        }
                    }

                    // Price chip
                    if let price = filter.maxPrice {
                        activeChip("≤ $\(String(format: "%.0f", price))") {
                            filter.maxPrice = nil
                        }
                    }

                    // Open now chip
                    if filter.isOpenNow {
                        activeChip("Open Now") {
                            filter.isOpenNow = false
                        }
                    }
                }
                .padding(.horizontal, FloatSpacing.md)
                .padding(.vertical, FloatSpacing.xs)
            }
        }
    }

    @ViewBuilder
    private func activeChip(_ label: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(FloatFont.caption(.semibold))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
            .accessibilityLabel("Remove \(label) filter")
        }
        .padding(.horizontal, FloatSpacing.sm)
        .padding(.vertical, 6)
        .background(FloatColors.primary.opacity(0.15))
        .foregroundStyle(FloatColors.primary)
        .cornerRadius(FloatSpacing.badgeRadius)
    }
}
