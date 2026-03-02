// MapViewModelTests.swift
// Float

import XCTest
import MapKit
@testable import Float

@MainActor
final class MapViewModelTests: XCTestCase {
    var viewModel: MapViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = MapViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // Test initial state
    func testInitialState() {
        XCTAssertTrue(viewModel.dealPins.isEmpty)
        XCTAssertTrue(viewModel.filteredPins.isEmpty)
        XCTAssertNil(viewModel.selectedPin)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.activeNowOnly)
    }
    
    // Test toggleActiveNowFilter
    func testToggleActiveNowFilter() {
        XCTAssertFalse(viewModel.activeNowOnly)
        viewModel.toggleActiveNowFilter()
        XCTAssertTrue(viewModel.activeNowOnly)
        viewModel.toggleActiveNowFilter()
        XCTAssertFalse(viewModel.activeNowOnly)
    }
    
    // Test selectPin toggles selection
    func testSelectPinTogglesSelection() {
        let pin = makeDealPin(category: "drink")
        
        // Select pin
        viewModel.selectPin(pin)
        XCTAssertEqual(viewModel.selectedPin?.id, pin.id)
        
        // Toggle off by selecting same pin again
        viewModel.selectPin(pin)
        XCTAssertNil(viewModel.selectedPin)
    }
    
    // Test selectPin replaces previous selection
    func testSelectPinReplacesPreviousSelection() {
        let pin1 = makeDealPin(category: "drink")
        let pin2 = makeDealPin(category: "food")
        
        viewModel.selectPin(pin1)
        XCTAssertEqual(viewModel.selectedPin?.id, pin1.id)
        
        // Select different pin replaces selection
        viewModel.selectPin(pin2)
        XCTAssertEqual(viewModel.selectedPin?.id, pin2.id)
    }
    
    // Test DealPin category colors
    func testDealPinCategoryColorDrink() {
        let pin = makeDealPin(category: "drink")
        XCTAssertEqual(pin.categoryColor, FloatColors.drinkColor)
    }
    
    func testDealPinCategoryColorFood() {
        let pin = makeDealPin(category: "food")
        XCTAssertEqual(pin.categoryColor, FloatColors.foodColor)
    }
    
    func testDealPinCategoryColorBoth() {
        let pin = makeDealPin(category: "both")
        XCTAssertEqual(pin.categoryColor, FloatColors.comboColor)
    }
    
    func testDealPinCategoryColorFlash() {
        let pin = makeDealPin(category: "flash")
        XCTAssertEqual(pin.categoryColor, FloatColors.eventColor)
    }
    
    func testDealPinCategoryColorDefault() {
        let pin = makeDealPin(category: "unknown")
        XCTAssertEqual(pin.categoryColor, FloatColors.primary)
    }
    
    // MARK: - Helpers
    
    private func makeDealPin(category: String) -> DealPin {
        let deal = Deal(
            id: UUID(),
            title: "Test Deal",
            description: nil,
            category: category,
            venueId: UUID(),
            venueName: "Test Venue",
            expiresAt: Date().addingTimeInterval(3600),
            startsAt: Date(),
            discountType: "percentage",
            discountValue: 20,
            terms: nil,
            distanceFromUser: 100
        )
        return DealPin(
            id: deal.id,
            coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            venueName: deal.venueName ?? "Venue",
            dealTitle: deal.title,
            category: category,
            expiresAt: deal.expiresAt ?? Date(),
            deal: deal
        )
    }
}
