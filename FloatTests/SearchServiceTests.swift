// SearchServiceTests.swift
// Float

import XCTest
@testable import Float

@MainActor
final class SearchServiceTests: XCTestCase {
    var service: SearchService!
    var testDeals: [Deal]!

    override func setUp() async throws {
        service = SearchService()
        testDeals = [
            Deal(id: UUID(), title: "2-for-1 Cocktails", description: "Buy one get one free cocktails",
                 category: "drink", venueId: UUID(), venueName: "The Daily Brew",
                 expiresAt: Date().addingTimeInterval(3600), startsAt: Date(),
                 discountType: "bogo", discountValue: nil, terms: nil,
                 distance: 300, distanceFromUser: 300),
            Deal(id: UUID(), title: "Happy Hour Nachos", description: "Half-price nachos",
                 category: "food", venueId: UUID(), venueName: "Food Court Pro",
                 expiresAt: Date().addingTimeInterval(7200), startsAt: Date(),
                 discountType: "percentage", discountValue: 50, terms: nil,
                 distance: 800, distanceFromUser: 800),
            Deal(id: UUID(), title: "30% Off Draft Beers", description: "All draft beers discounted",
                 category: "drink", venueId: UUID(), venueName: "Happy Hour Haven",
                 expiresAt: Date().addingTimeInterval(1800), startsAt: Date(),
                 discountType: "percentage", discountValue: 30, terms: nil,
                 distance: 5000, distanceFromUser: 5000),
            Deal(id: UUID(), title: "Burger & Beer Combo", description: "House burger plus draft beer",
                 category: "both", venueId: UUID(), venueName: "The Mix",
                 expiresAt: Date().addingTimeInterval(5400), startsAt: Date().addingTimeInterval(-100),
                 discountType: "percentage", discountValue: 20, terms: nil,
                 distance: 12000, distanceFromUser: 12000),
            Deal(id: UUID(), title: "Flash: $3 Shots", description: "Well shots tonight only",
                 category: "flash", venueId: UUID(), venueName: "Late Night Eats",
                 expiresAt: Date().addingTimeInterval(900), startsAt: Date(),
                 discountType: "fixed", discountValue: 3, terms: nil,
                 distance: 20000, distanceFromUser: 20000),
        ]
    }

    // MARK: - Text Search

    func testTextSearchExactMatch() {
        var filter = SearchFilter()
        filter.query = "Nachos"
        let results = service.search(deals: testDeals, filter: filter)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Happy Hour Nachos")
    }

    func testTextSearchPartialMatch() {
        var filter = SearchFilter()
        filter.query = "Beer"
        let results = service.search(deals: testDeals, filter: filter)
        XCTAssertEqual(results.count, 2) // "30% Off Draft Beers" + "Burger & Beer Combo"
    }

    func testTextSearchCaseInsensitive() {
        var filter = SearchFilter()
        filter.query = "COCKTAILS"
        let results = service.search(deals: testDeals, filter: filter)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "2-for-1 Cocktails")
    }

    // MARK: - Category Filter

    func testCategoryFilterSingle() {
        var filter = SearchFilter()
        filter.categories = [.food]
        let results = service.search(deals: testDeals, filter: filter)
        XCTAssertTrue(results.allSatisfy { $0.category.lowercased() == "food" })
        XCTAssertEqual(results.count, 1)
    }

    func testCategoryFilterMultiple() {
        var filter = SearchFilter()
        filter.categories = [.drinks, .food]
        let results = service.search(deals: testDeals, filter: filter)
        XCTAssertEqual(results.count, 3) // 2 drinks + 1 food
    }

    func testCategoryFilterEmptyPassesAll() {
        let filter = SearchFilter() // empty categories
        let results = service.search(deals: testDeals, filter: filter)
        XCTAssertEqual(results.count, testDeals.count)
    }

    // MARK: - Distance Filter

    func testDistanceFilterWithinRange() {
        var filter = SearchFilter()
        filter.maxDistance = 1.0 // 1 mile = ~1609m
        let results = service.search(deals: testDeals, filter: filter)
        // 300m and 800m are within 1609m
        XCTAssertEqual(results.count, 2)
    }

    func testDistanceFilterOutsideRange() {
        var filter = SearchFilter()
        filter.maxDistance = 0.5 // ~804m
        let results = service.search(deals: testDeals, filter: filter)
        // Only 300m deal passes
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "2-for-1 Cocktails")
    }

    // MARK: - Discount Filter

    func testDiscountFilterThreshold() {
        var filter = SearchFilter()
        filter.minDiscount = 30
        let results = service.search(deals: testDeals, filter: filter)
        // 50% nachos, 30% beers pass; bogo/fixed/20% don't
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { ($0.discountValue ?? 0) >= 30 })
    }

    // MARK: - Sort

    func testSortByDiscountDescending() {
        var filter = SearchFilter()
        filter.sortBy = .discount
        let results = service.search(deals: testDeals, filter: filter)
        let values = results.compactMap(\.discountValue)
        XCTAssertEqual(values, values.sorted(by: >))
    }

    func testSortByDistanceAscending() {
        var filter = SearchFilter()
        filter.sortBy = .distance
        let results = service.search(deals: testDeals, filter: filter)
        let distances = results.compactMap(\.distanceFromUser)
        XCTAssertEqual(distances, distances.sorted())
    }

    // MARK: - Combined Filters

    func testCombinedTextCategoryDistance() {
        var filter = SearchFilter()
        filter.query = "Beer"
        filter.categories = [.drinks]
        filter.maxDistance = 5.0 // ~8046m
        let results = service.search(deals: testDeals, filter: filter)
        // "30% Off Draft Beers" is drink + has "beer" + 5000m < 8046m
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "30% Off Draft Beers")
    }

    // MARK: - Reset

    func testResetFilterReturnsAllDeals() {
        var filter = SearchFilter()
        filter.query = "Nachos"
        filter.categories = [.food]
        filter.minDiscount = 40
        let filtered = service.search(deals: testDeals, filter: filter)
        XCTAssertEqual(filtered.count, 1)

        filter.reset()
        let all = service.search(deals: testDeals, filter: filter)
        XCTAssertEqual(all.count, testDeals.count)
    }
}
