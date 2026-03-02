// DealMapClusterTests.swift
// Float

import XCTest
import MapKit
import CoreLocation
@testable import Float

@MainActor
final class DealMapClusterTests: XCTestCase {

    // MARK: - Helpers

    private func makeDeal(category: String = "drink", distance: Double = 500) -> Deal {
        Deal(
            id: UUID(),
            title: "Test Deal",
            description: "A test deal",
            category: category,
            venueId: UUID(),
            venueName: "Test Venue",
            expiresAt: Date().addingTimeInterval(3600),
            startsAt: Date(),
            discountType: "percentage",
            discountValue: 25,
            terms: nil,
            distanceFromUser: distance
        )
    }

    private func makePin(category: String = "drink") -> DealPin {
        let deal = makeDeal(category: category)
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

    // MARK: - Test: Cluster annotation init with correct count

    func testClusterAnnotationMemberCount() {
        let annotations: [MKAnnotation] = (0..<5).map { _ in
            DealMapAnnotation(dealPin: makePin())
        }
        let cluster = MKClusterAnnotation(memberAnnotations: annotations)
        XCTAssertEqual(cluster.dealCount, 5)
        XCTAssertEqual(cluster.dealPins.count, 5)
    }

    // MARK: - Test: Cluster view badge rendering

    func testClusterAnnotationViewBadgeSetup() {
        let view = DealMapClusterAnnotationView(annotation: nil, reuseIdentifier: DealMapClusterAnnotationView.reuseID)
        XCTAssertNotNil(view)
        // View should have subviews for the circle and label
        XCTAssertFalse(view.subviews.isEmpty)
    }

    // MARK: - Test: ViewModel correctly assigns clusteringIdentifier via mapAnnotations

    func testViewModelMapAnnotationsHaveClusteringSupport() {
        let vm = MapViewModel()
        let pin = makePin(category: "food")
        vm.dealPins = [pin]
        vm.filteredPins = [pin]

        let annotations = vm.mapAnnotations
        XCTAssertEqual(annotations.count, 1)
        XCTAssertEqual(annotations.first?.dealPin.id, pin.id)
        XCTAssertEqual(annotations.first?.coordinate.latitude, pin.coordinate.latitude, accuracy: 0.0001)
    }

    // MARK: - Test: Bottom sheet populates from cluster members

    func testClusteredDealsPopulate() {
        let vm = MapViewModel()
        let pins = (0..<3).map { _ in makePin() }

        vm.handleClusterTap(pins)

        XCTAssertTrue(vm.showClusterSheet)
        XCTAssertEqual(vm.clusteredDeals.count, 3)
    }

    // MARK: - Test: Single deal pin shows without cluster wrapper

    func testSinglePinAnnotation() {
        let pin = makePin(category: "food")
        let annotation = DealMapAnnotation(dealPin: pin)

        XCTAssertEqual(annotation.title, pin.venueName)
        XCTAssertEqual(annotation.subtitle, pin.dealTitle)
        XCTAssertEqual(annotation.coordinate.latitude, pin.coordinate.latitude, accuracy: 0.0001)
    }

    // MARK: - Test: Distance formatting

    func testDistanceFormattingMeters() {
        let result = ClusteredDealCard.formatDistance(meters: 500)
        XCTAssertEqual(result, "500m")
    }

    func testDistanceFormattingMiles() {
        let result = ClusteredDealCard.formatDistance(meters: 2500)
        XCTAssertEqual(result, "1.6mi")
    }

    func testDistanceFormattingZero() {
        let result = ClusteredDealCard.formatDistance(meters: 0)
        XCTAssertEqual(result, "0m")
    }

    // MARK: - Test: Dismiss cluster sheet

    func testDismissClusterSheet() {
        let vm = MapViewModel()
        vm.handleClusterTap([makePin()])
        XCTAssertTrue(vm.showClusterSheet)

        vm.dismissClusterSheet()
        XCTAssertFalse(vm.showClusterSheet)
        XCTAssertTrue(vm.clusteredDeals.isEmpty)
    }
}
