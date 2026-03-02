// SearchFilterView.swift
// Float

import SwiftUI

struct SearchFilterView: View {
    @Binding var filter: SearchFilter
    @Environment(\.dismiss) var dismiss
    @State private var draft: SearchFilter

    init(filter: Binding<SearchFilter>) {
        self._filter = filter
        self._draft = State(initialValue: filter.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FloatSpacing.lg) {

                    // Category multi-select chips
                    filterSection("Category") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: FloatSpacing.sm) {
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
                    }

                    Divider()

                    // Distance slider
                    filterSection("Max Distance",
                                  detail: draft.maxDistance.map { "\(String(format: "%.1f", $0)) mi" } ?? "Any") {
                        Slider(
                            value: Binding(
                                get: { draft.maxDistance ?? 25.0 },
                                set: { draft.maxDistance = $0 }
                            ),
                            in: 0.5...25.0,
                            step: 0.5
                        )
                        .tint(FloatColors.primary)
                        HStack {
                            Text("0.5 mi").font(FloatFont.caption()).foregroundStyle(FloatColors.adaptiveTextSecondary)
                            Spacer()
                            Text("25 mi").font(FloatFont.caption()).foregroundStyle(FloatColors.adaptiveTextSecondary)
                        }

                        if draft.maxDistance != nil {
                            Button("Clear distance") { draft.maxDistance = nil }
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.primary)
                        }
                    }

                    Divider()

                    // Min discount stepper
                    filterSection("Minimum Discount",
                                  detail: (draft.minDiscount ?? 0) > 0 ? "\(draft.minDiscount!)%+" : "Any") {
                        Stepper(
                            value: Binding(
                                get: { draft.minDiscount ?? 0 },
                                set: { draft.minDiscount = $0 == 0 ? nil : $0 }
                            ),
                            in: 0...90,
                            step: 5
                        ) {
                            Text("\(draft.minDiscount ?? 0)%")
                                .font(FloatFont.body(.semibold))
                        }
                    }

                    Divider()

                    // Max price
                    filterSection("Max Price") {
                        HStack {
                            Text("$")
                                .font(FloatFont.body(.semibold))
                            TextField("Any", value: $draft.maxPrice, format: .number)
                                .keyboardType(.decimalPad)
                                .font(FloatFont.body())
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Divider()

                    // Open Now toggle
                    Toggle(isOn: $draft.isOpenNow) {
                        Text("Open Now")
                            .font(FloatFont.headline())
                    }
                    .tint(FloatColors.primary)

                    Divider()

                    // Sort picker
                    filterSection("Sort By") {
                        Picker("Sort", selection: $draft.sortBy) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(FloatSpacing.md)
            }
            .background(FloatColors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        draft = SearchFilter()
                    }
                    .foregroundStyle(FloatColors.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        filter = draft
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(FloatColors.primary)
                }
            }
        }
    }

    @ViewBuilder
    private func filterSection<Content: View>(_ title: String, detail: String? = nil, @ViewBuilder content: () -> Content) -> some View {
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
