// DealMapClusterAnnotation.swift
// Float

import MapKit

/// Custom annotation for individual deal pins on the MKMapView.
/// Supports MapKit's built-in clustering via `clusteringIdentifier`.
final class DealMapAnnotation: MKPointAnnotation {
    let dealPin: DealPin

    init(dealPin: DealPin) {
        self.dealPin = dealPin
        super.init()
        self.coordinate = dealPin.coordinate
        self.title = dealPin.venueName
        self.subtitle = dealPin.dealTitle
    }
}

/// Wrapper around MKClusterAnnotation to expose the member deal pins.
extension MKClusterAnnotation {
    /// All DealPin models contained in this cluster.
    var dealPins: [DealPin] {
        memberAnnotations.compactMap { ($0 as? DealMapAnnotation)?.dealPin }
    }

    /// Convenience count of member deal pins.
    var dealCount: Int {
        memberAnnotations.count
    }
}
