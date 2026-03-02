// SearchFilter.swift
// Float

import Foundation

// MARK: - Sort Option

enum SortOption: String, Codable, CaseIterable, Identifiable {
    case relevance = "Relevance"
    case distance = "Distance"
    case discount = "Discount"
    case newest = "Newest"

    var id: String { rawValue }
}

// MARK: - Search Filter

struct SearchFilter: Codable, Identifiable, Equatable {
    var id = UUID()
    var query: String = ""
    var categories: Set<DealCategory> = []
    var maxDistance: Double? = nil       // in miles
    var minDiscount: Int? = nil          // percentage
    var maxPrice: Double? = nil
    var isOpenNow: Bool = false
    var sortBy: SortOption = .relevance

    var isDefault: Bool {
        query.isEmpty &&
        categories.isEmpty &&
        maxDistance == nil &&
        minDiscount == nil &&
        maxPrice == nil &&
        !isOpenNow &&
        sortBy == .relevance
    }

    var activeFilterCount: Int {
        var count = 0
        if !categories.isEmpty { count += 1 }
        if maxDistance != nil { count += 1 }
        if let d = minDiscount, d > 0 { count += 1 }
        if maxPrice != nil { count += 1 }
        if isOpenNow { count += 1 }
        return count
    }

    mutating func reset() {
        query = ""
        categories = []
        maxDistance = nil
        minDiscount = nil
        maxPrice = nil
        isOpenNow = false
        sortBy = .relevance
    }
}

// MARK: - Saved Filter Preset

struct SavedFilterPreset: Codable, Identifiable {
    let id: UUID
    var name: String
    var filter: SearchFilter

    init(name: String, filter: SearchFilter) {
        self.id = UUID()
        self.name = name
        self.filter = filter
    }
}
