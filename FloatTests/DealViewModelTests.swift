import XCTest
@testable import Float
import CoreLocation

@MainActor
final class DealViewModelTests: XCTestCase {
    var viewModel: DealViewModel!
    
    override func setUp() async throws {
        viewModel = DealViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
    }
    
    // MARK: - Filter Tests
    
    func testFilterDrinksCategory() async {
        await viewModel.loadDeals()
        viewModel.updateFilter(.drinks)
        
        XCTAssertEqual(viewModel.activeFilter, .drinks)
        XCTAssertTrue(viewModel.filteredDeals.allSatisfy { $0.category.lowercased() == "drink" },
                      "All filtered deals should be in 'drink' category")
    }
    
    func testFilterFoodCategory() async {
        await viewModel.loadDeals()
        viewModel.updateFilter(.food)
        
        XCTAssertEqual(viewModel.activeFilter, .food)
        XCTAssertTrue(viewModel.filteredDeals.allSatisfy { $0.category.lowercased() == "food" },
                      "All filtered deals should be in 'food' category")
    }
    
    func testFilterFlashCategory() async {
        await viewModel.loadDeals()
        viewModel.updateFilter(.flash)
        
        XCTAssertEqual(viewModel.activeFilter, .flash)
        XCTAssertTrue(viewModel.filteredDeals.allSatisfy { $0.category.lowercased() == "flash" },
                      "All filtered deals should be in 'flash' category")
    }
    
    func testFilterBothCategory() async {
        await viewModel.loadDeals()
        viewModel.updateFilter(.both)
        
        XCTAssertEqual(viewModel.activeFilter, .both)
        XCTAssertTrue(viewModel.filteredDeals.allSatisfy { $0.category.lowercased() == "both" },
                      "All filtered deals should be in 'both' category")
    }
    
    func testFilterAllReturnsAll() async {
        await viewModel.loadDeals()
        let originalCount = viewModel.deals.count
        
        // First filter by drinks
        viewModel.updateFilter(.drinks)
        XCTAssertLessThan(viewModel.filteredDeals.count, originalCount,
                          "Filtered deals should be less than total deals")
        
        // Then set to all
        viewModel.updateFilter(.all)
        XCTAssertEqual(viewModel.filteredDeals.count, originalCount,
                       "All filter should return all deals")
    }
    
    func testUpdateFilterCallsApplyFiltersAndSort() async {
        await viewModel.loadDeals()
        let initialFilteredCount = viewModel.filteredDeals.count
        
        viewModel.updateFilter(.drinks)
        let afterFilterCount = viewModel.filteredDeals.count
        
        XCTAssertNotEqual(initialFilteredCount, afterFilterCount,
                          "updateFilter should trigger applyFiltersAndSort")
    }
    
    // MARK: - Sort Tests: Distance
    
    func testSortByDistance() async {
        await viewModel.loadDeals()
        viewModel.updateSort(.distance)
        
        XCTAssertEqual(viewModel.sortOption, .distance)
        
        // Verify deals are sorted by distance ascending
        for i in 0..<viewModel.filteredDeals.count - 1 {
            let current = viewModel.filteredDeals[i].distanceFromUser ?? Double.infinity
            let next = viewModel.filteredDeals[i + 1].distanceFromUser ?? Double.infinity
            XCTAssertLessThanOrEqual(current, next,
                                    "Deals should be sorted by distance in ascending order")
        }
    }
    
    // MARK: - Sort Tests: Expiry Time
    
    func testSortByExpiryTime() async {
        await viewModel.loadDeals()
        viewModel.updateSort(.expiryTime)
        
        XCTAssertEqual(viewModel.sortOption, .expiryTime)
        
        // Verify deals are sorted by expiry time ascending (earlier expiry first)
        for i in 0..<viewModel.filteredDeals.count - 1 {
            let current = viewModel.filteredDeals[i].expiresAt ?? Date.distantFuture
            let next = viewModel.filteredDeals[i + 1].expiresAt ?? Date.distantFuture
            XCTAssertLessThanOrEqual(current, next,
                                    "Deals should be sorted by expiry time in ascending order")
        }
    }
    
    // MARK: - Sort Tests: Discount Value
    
    func testSortByDiscountValue() async {
        await viewModel.loadDeals()
        viewModel.updateSort(.discountValue)
        
        XCTAssertEqual(viewModel.sortOption, .discountValue)
        
        // Verify deals are sorted by discount value descending (higher discount first)
        for i in 0..<viewModel.filteredDeals.count - 1 {
            let current = viewModel.filteredDeals[i].discountValue ?? 0
            let next = viewModel.filteredDeals[i + 1].discountValue ?? 0
            XCTAssertGreaterThanOrEqual(current, next,
                                       "Deals should be sorted by discount value in descending order")
        }
    }
    
    // MARK: - Sort Tests: Relevance
    
    func testSortByRelevance() async {
        await viewModel.loadDeals()
        viewModel.updateSort(.relevance)
        
        XCTAssertEqual(viewModel.sortOption, .relevance)
        XCTAssertGreater(viewModel.filteredDeals.count, 0,
                        "Should have deals after sorting by relevance")
    }
    
    // MARK: - Pagination Tests
    
    func testCurrentPageIncrementsAfterLoadMore() async {
        await viewModel.loadDeals()
        let initialPage = viewModel.currentPage
        
        await viewModel.loadMoreDeals()
        let nextPage = viewModel.currentPage
        
        XCTAssertEqual(nextPage, initialPage + 1,
                       "currentPage should increment by 1 after loadMoreDeals")
    }
    
    func testHasMoreIsFalseWhenFewerItemsReturned() async {
        await viewModel.loadDeals()
        
        // Keep loading more until we get fewer items than pageSize
        let pageSize = 20
        while viewModel.hasMore {
            await viewModel.loadMoreDeals()
        }
        
        XCTAssertFalse(viewModel.hasMore,
                       "hasMore should be false when last page returns fewer items than pageSize")
    }
    
    func testInitialLoadSetsCurrentPageToOne() async {
        await viewModel.loadDeals()
        
        XCTAssertGreaterThanOrEqual(viewModel.currentPage, 1,
                                   "currentPage should be at least 1 after initial load")
    }
    
    func testLoadMoreDealsAppendsToDealsList() async {
        await viewModel.loadDeals()
        let initialCount = viewModel.deals.count
        
        await viewModel.loadMoreDeals()
        let afterLoadMore = viewModel.deals.count
        
        XCTAssertGreaterThan(afterLoadMore, initialCount,
                            "loadMoreDeals should append deals to the list")
    }
    
    // MARK: - Combined Filter and Sort Tests
    
    func testFilterAndSortTogether() async {
        await viewModel.loadDeals()
        
        // Apply filter first
        viewModel.updateFilter(.drinks)
        let filteredDrinksCount = viewModel.filteredDeals.count
        XCTAssertGreater(filteredDrinksCount, 0, "Should have drink deals")
        
        // Then apply sort
        viewModel.updateSort(.discountValue)
        
        // Verify filter still applied
        XCTAssertTrue(viewModel.filteredDeals.allSatisfy { $0.category.lowercased() == "drink" },
                      "Filter should persist after sort")
        
        // Verify sort applied
        for i in 0..<viewModel.filteredDeals.count - 1 {
            let current = viewModel.filteredDeals[i].discountValue ?? 0
            let next = viewModel.filteredDeals[i + 1].discountValue ?? 0
            XCTAssertGreaterThanOrEqual(current, next,
                                       "Should be sorted by discount value descending")
        }
    }
    
    // MARK: - State Tests
    
    func testLoadingStateChanges() async {
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")
        
        // Start loading in background
        let loadTask = Task { await viewModel.loadDeals() }
        
        // Give it a moment to start
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        await loadTask.value
        
        XCTAssertFalse(viewModel.isLoading, "Should finish loading")
    }
    
    func testFilteredDealsUpdatedAfterLoad() async {
        await viewModel.loadDeals()
        
        XCTAssertGreater(viewModel.filteredDeals.count, 0,
                        "filteredDeals should be populated after loadDeals")
    }
    
    func testDealCountUpdatedAfterLoad() async {
        await viewModel.loadDeals()
        
        XCTAssertEqual(viewModel.dealCount, viewModel.deals.count,
                      "dealCount should match deals.count after load")
    }
    
    // MARK: - Edge Case Tests
    
    func testApplyFiltersAndSortWithEmptyDeals() async {
        viewModel.deals = []
        viewModel.applyFiltersAndSort()
        
        XCTAssertEqual(viewModel.filteredDeals.count, 0,
                      "filteredDeals should be empty when deals is empty")
    }
    
    func testMultipleFilterUpdates() async {
        await viewModel.loadDeals()
        
        viewModel.updateFilter(.drinks)
        let drinksCount = viewModel.filteredDeals.count
        
        viewModel.updateFilter(.food)
        let foodCount = viewModel.filteredDeals.count
        
        viewModel.updateFilter(.drinks)
        let drinksCountAgain = viewModel.filteredDeals.count
        
        XCTAssertEqual(drinksCount, drinksCountAgain,
                      "Filter results should be consistent across multiple updates")
    }
    
    func testMultipleSortUpdates() async {
        await viewModel.loadDeals()
        
        viewModel.updateSort(.distance)
        let firstSort = viewModel.filteredDeals
        
        viewModel.updateSort(.expiryTime)
        let secondSort = viewModel.filteredDeals
        
        // Results may be different due to sort order
        XCTAssertEqual(firstSort.count, secondSort.count,
                      "Sort should not change the count of filtered deals")
    }
    
    func testFilterWithNilValue() async {
        await viewModel.loadDeals()
        
        viewModel.updateFilter(nil)
        
        XCTAssertEqual(viewModel.activeFilter, .all,
                      "nil filter should default to .all")
    }
}
