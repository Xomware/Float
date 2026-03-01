// DealFiltersView.swift
// Float

import SwiftUI

// MARK: - Filter State

struct DealFilterState: Equatable {
    var categories: Set<DealCategory> = []
    var maxDistanceMiles: Double = 5.0
    var minDiscountPercent: Double = 0
    var minRating: Double = 0
    var activeCount: Int {
        var count = 0
        if !categories.isEmpty { count += 1 }
        if maxDistanceMiles < 5.0 { count += 1 }
        if minDiscountPercent > 0 { count += 1 }
        if minRating > 0 { count += 1 }
        return count
    }
    var isActive: Bool { activeCount > 0 }
    mutating func reset() {
        categories = []
        maxDistanceMiles = 5.0
        minDiscountPercent = 0
        minRating = 0
    }
}

// MARK: - DealFiltersView

struct DealFiltersView: View {
    @Binding var filterState: DealFilterState
    @Environment(\.dismiss) var dismiss
    @State private var draft: DealFilterState

    init(filterState: Binding<DealFilterState>) {
        self._filterState = filterState
        self._draft = State(initialValue: filterState.wrappedValue)
    }

    let distanceOptions: [Double] = [0.25, 0.5, 1.0, 2.0, 5.0]
    let ratingOptions: [Double] = [0, 3.0, 3.5, 4.0, 4.5]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FloatSpacing.lg) {

                    // Category filter
                    filterSection("Category") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: FloatSpacing.sm) {
                            ForEach(DealCategory.allCases.filter { $0 != .all }, id: \.self) { cat in
                                CategoryToggleChip(
                                    category: cat,
                                    isSelected: draft.categories.contains(cat),
                                    action: {
                                        if draft.categories.contains(cat) {
                                            draft.categories.remove(cat)
                                        } else {
                                            draft.categories.insert(cat)
                                        }
                                    }
                                )
                            }
                        }
                    }

                    Divider().background(FloatColors.adaptiveSeparator)

                    // Distance
                    filterSection("Max Distance") {
                        HStack(spacing: FloatSpacing.sm) {
                            ForEach(distanceOptions, id: \.self) { miles in
                                Button(action: { draft.maxDistanceMiles = miles }) {
                                    Text(miles < 1 ? String(format: "%.2g mi", miles) : "\(Int(miles)) mi")
                                        .font(FloatFont.caption(.semibold))
                                        .padding(.horizontal, FloatSpacing.sm)
                                        .padding(.vertical, 8)
                                        .background(
                                            draft.maxDistanceMiles == miles
                                                ? FloatColors.primary
                                                : FloatColors.adaptiveCardBackground
                                        )
                                        .foregroundStyle(draft.maxDistanceMiles == miles ? .white : FloatColors.adaptiveTextPrimary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }

                    Divider().background(FloatColors.adaptiveSeparator)

                    // Min discount
                    filterSection("Minimum Discount", detail: draft.minDiscountPercent > 0 ? "\(Int(draft.minDiscountPercent))%+" : "Any") {
                        Slider(value: $draft.minDiscountPercent, in: 0...50, step: 5)
                            .tint(FloatColors.primary)
                        HStack {
                            Text("Any").font(FloatFont.caption()).foregroundStyle(FloatColors.adaptiveTextSecondary)
                            Spacer()
                            Text("50%+").font(FloatFont.caption()).foregroundStyle(FloatColors.adaptiveTextSecondary)
                        }
                    }

                    Divider().background(FloatColors.adaptiveSeparator)

                    // Venue rating
                    let ratingDetail = draft.minRating > 0
                        ? "\(String(format: "%.1f", draft.minRating))★+"
                        : "Any"
                    filterSection("Minimum Venue Rating", detail: ratingDetail) {
                        HStack(spacing: FloatSpacing.sm) {
                            ForEach(ratingOptions, id: \.self) { rating in
                                Button(action: { draft.minRating = rating }) {
                                    Text(rating == 0 ? "Any" : "\(String(format: "%.1f", rating))★")
                                        .font(FloatFont.caption(.semibold))
                                        .padding(.horizontal, FloatSpacing.sm)
                                        .padding(.vertical, 8)
                                        .background(draft.minRating == rating ? FloatColors.primary : FloatColors.adaptiveCardBackground)
                                        .foregroundStyle(draft.minRating == rating ? .white : FloatColors.adaptiveTextPrimary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(FloatSpacing.md)
            }
            .background(FloatColors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Filter Deals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        draft.reset()
                    }
                    .foregroundStyle(FloatColors.primary)
                    .disabled(!draft.isActive)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        filterState = draft
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(FloatColors.primary)
                }
            }
        }
    }

    @ViewBuilder
    func filterSection<Content: View>(_ title: String, detail: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: FloatSpacing.sm) {
            HStack {
                Text(title)
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                Spacer()
                if let detail {
                    Text(detail)
                        .font(FloatFont.caption())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                }
            }
            content()
        }
    }
}

// MARK: - CategoryToggleChip

struct CategoryToggleChip: View {
    let category: DealCategory
    let isSelected: Bool
    let action: () -> Void

    var icon: String {
        switch category {
        case .drinks: return "🍹"
        case .food: return "🍔"
        case .both: return "🎉"
        case .flash: return "⚡️"
        default: return "✨"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: FloatSpacing.xs) {
                Text(icon).font(.body)
                Text(category.rawValue)
                    .font(FloatFont.caption(.semibold))
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? FloatColors.primary.opacity(0.15) : FloatColors.adaptiveCardBackground)
            .foregroundStyle(isSelected ? FloatColors.primary : FloatColors.adaptiveTextPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? FloatColors.primary : Color.clear, lineWidth: 1.5)
            )
            .cornerRadius(10)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isSelected)
        }
        .accessibilityLabel("\(category.rawValue) filter")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    DealFiltersView(filterState: .constant(DealFilterState()))
        .preferredColorScheme(.dark)
}
