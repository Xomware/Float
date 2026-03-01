// SearchService.swift
// Float

import SwiftUI
import Combine

@MainActor
final class SearchService: ObservableObject {
    @Published var results: [Deal] = []
    @Published var isSearching = false

    private var searchTask: Task<Void, Never>?

    /// Perform a debounced search. Call this whenever the filter changes.
    func debouncedSearch(deals: [Deal], filter: SearchFilter, delay: UInt64 = 300_000_000) {
        searchTask?.cancel()
        guard !deals.isEmpty else {
            results = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            isSearching = true
            results = search(deals: deals, filter: filter)
            isSearching = false
        }
    }

    /// Synchronous search + filter + sort pipeline.
    func search(deals: [Deal], filter: SearchFilter) -> [Deal] {
        var result = deals

        // 1. Text filter (fuzzy: contains, case-insensitive)
        if !filter.query.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = filter.query.lowercased()
            result = result.filter { deal in
                deal.title.lowercased().contains(q) ||
                (deal.description?.lowercased().contains(q) ?? false) ||
                (deal.venueName?.lowercased().contains(q) ?? false)
            }
        }

        // 2. Category filter
        if !filter.categories.isEmpty {
            result = result.filter { deal in
                filter.categories.contains(where: { cat in
                    categoryMatches(cat, dealCategory: deal.category)
                })
            }
        }

        // 3. Distance filter (deal.distanceFromUser is in meters, filter.maxDistance is in miles)
        if let maxMiles = filter.maxDistance {
            let maxMeters = maxMiles * 1609.34
            result = result.filter { ($0.distanceFromUser ?? 0) <= maxMeters }
        }

        // 4. Discount filter
        if let minDiscount = filter.minDiscount, minDiscount > 0 {
            result = result.filter { deal in
                guard deal.discountType == "percentage", let val = deal.discountValue else { return false }
                return Int(val) >= minDiscount
            }
        }

        // 5. Price filter
        if let maxPrice = filter.maxPrice {
            result = result.filter { deal in
                guard let val = deal.discountValue else { return true }
                return val <= maxPrice
            }
        }

        // 6. Open now filter (requires venue info — skip for deals without it)
        // For now deals don't carry isOpenNow; this is a placeholder for venue integration.

        // 7. Sort
        result = sortDeals(result, by: filter.sortBy, query: filter.query)

        return result
    }

    // MARK: - Helpers

    private func categoryMatches(_ category: DealCategory, dealCategory: String) -> Bool {
        switch category {
        case .all: return true
        case .drinks: return dealCategory.lowercased() == "drink"
        case .food: return dealCategory.lowercased() == "food"
        case .both: return dealCategory.lowercased() == "both"
        case .flash: return dealCategory.lowercased() == "flash"
        }
    }

    private func sortDeals(_ deals: [Deal], by option: SortOption, query: String) -> [Deal] {
        switch option {
        case .relevance:
            if query.isEmpty { return deals }
            let q = query.lowercased()
            return deals.sorted { a, b in
                relevanceScore(a, query: q) > relevanceScore(b, query: q)
            }
        case .distance:
            return deals.sorted {
                ($0.distanceFromUser ?? .infinity) < ($1.distanceFromUser ?? .infinity)
            }
        case .discount:
            return deals.sorted {
                ($0.discountValue ?? 0) > ($1.discountValue ?? 0)
            }
        case .newest:
            return deals.sorted {
                ($0.startsAt ?? .distantPast) > ($1.startsAt ?? .distantPast)
            }
        }
    }

    private func relevanceScore(_ deal: Deal, query: String) -> Int {
        var score = 0
        if deal.title.lowercased().hasPrefix(query) { score += 3 }
        else if deal.title.lowercased().contains(query) { score += 2 }
        if deal.venueName?.lowercased().contains(query) == true { score += 1 }
        if deal.description?.lowercased().contains(query) == true { score += 1 }
        return score
    }
}
