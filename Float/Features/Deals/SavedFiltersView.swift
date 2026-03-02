// SavedFiltersView.swift
// Float

import SwiftUI

@MainActor
final class SavedFiltersManager: ObservableObject {
    @Published var presets: [SavedFilterPreset] = []

    private let storageKey = "float_saved_filter_presets"

    init() { load() }

    func save(name: String, filter: SearchFilter) {
        let preset = SavedFilterPreset(name: name, filter: filter)
        presets.insert(preset, at: 0)
        persist()
    }

    func delete(_ preset: SavedFilterPreset) {
        presets.removeAll { $0.id == preset.id }
        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SavedFilterPreset].self, from: data) else { return }
        presets = decoded
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

struct SavedFiltersView: View {
    @Binding var currentFilter: SearchFilter
    @StateObject private var manager = SavedFiltersManager()
    @State private var newPresetName = ""
    @State private var showSaveField = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Save current
                Section("Save Current Filter") {
                    if showSaveField {
                        HStack {
                            TextField("Preset name", text: $newPresetName)
                                .font(FloatFont.body())
                            Button("Save") {
                                guard !newPresetName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                manager.save(name: newPresetName, filter: currentFilter)
                                newPresetName = ""
                                showSaveField = false
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(FloatColors.primary)
                        }
                    } else {
                        Button {
                            showSaveField = true
                        } label: {
                            Label("Save current filters as preset", systemImage: "plus.circle.fill")
                                .foregroundStyle(FloatColors.primary)
                        }
                        .disabled(currentFilter.isDefault)
                    }
                }

                // Saved presets
                if !manager.presets.isEmpty {
                    Section("Saved Presets") {
                        ForEach(manager.presets) { preset in
                            Button {
                                currentFilter = preset.filter
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(FloatFont.body(.semibold))
                                        .foregroundStyle(FloatColors.adaptiveTextPrimary)
                                    Text(presetSummary(preset.filter))
                                        .font(FloatFont.caption())
                                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for i in indexSet { manager.delete(manager.presets[i]) }
                        }
                    }
                }
            }
            .navigationTitle("Saved Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(FloatColors.primary)
                }
            }
        }
    }

    private func presetSummary(_ filter: SearchFilter) -> String {
        var parts: [String] = []
        if !filter.categories.isEmpty {
            parts.append(filter.categories.map(\.rawValue).joined(separator: ", "))
        }
        if let d = filter.maxDistance { parts.append("≤\(String(format: "%.1f", d))mi") }
        if let d = filter.minDiscount, d > 0 { parts.append("≥\(d)%") }
        if let p = filter.maxPrice { parts.append("≤$\(String(format: "%.0f", p))") }
        if filter.isOpenNow { parts.append("Open Now") }
        return parts.isEmpty ? "No filters" : parts.joined(separator: " · ")
    }
}
