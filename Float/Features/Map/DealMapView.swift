// DealMapView.swift
// Float

import SwiftUI
import MapKit

/// UIViewRepresentable wrapper for MKMapView with clustering support.
struct DealMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let annotations: [DealMapAnnotation]
    let onSelectAnnotation: (DealMapAnnotation) -> Void
    let onSelectCluster: (MKClusterAnnotation) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.register(DealMapAnnotationView.self, forAnnotationViewWithReuseIdentifier: DealMapAnnotationView.reuseID)
        mapView.register(DealMapClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: DealMapClusterAnnotationView.reuseID)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update region
        let currentCenter = mapView.region.center
        let newCenter = region.center
        let threshold = 0.001
        if abs(currentCenter.latitude - newCenter.latitude) > threshold ||
           abs(currentCenter.longitude - newCenter.longitude) > threshold {
            mapView.setRegion(region, animated: true)
        }

        // Diff annotations
        let existing = Set(mapView.annotations.compactMap { ($0 as? DealMapAnnotation)?.dealPin.id })
        let incoming = Set(annotations.map { $0.dealPin.id })

        let toRemove = mapView.annotations.filter {
            guard let a = $0 as? DealMapAnnotation else { return false }
            return !incoming.contains(a.dealPin.id)
        }
        let toAdd = annotations.filter { !existing.contains($0.dealPin.id) }

        if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }
        if !toAdd.isEmpty {
            mapView.addAnnotations(toAdd)
            context.coordinator.newAnnotationIDs = Set(toAdd.map { $0.dealPin.id })
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: DealMapView
        var newAnnotationIDs: Set<UUID> = []

        init(_ parent: DealMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: DealMapClusterAnnotationView.reuseID, for: cluster) as! DealMapClusterAnnotationView
                return view
            }

            if let dealAnnotation = annotation as? DealMapAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: DealMapAnnotationView.reuseID, for: dealAnnotation) as! DealMapAnnotationView
                return view
            }

            return nil
        }

        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            for view in views {
                guard let pinView = view as? DealMapAnnotationView,
                      let annotation = pinView.annotation as? DealMapAnnotation,
                      newAnnotationIDs.contains(annotation.dealPin.id) else { continue }
                pinView.animatePulse()
                newAnnotationIDs.remove(annotation.dealPin.id)
            }
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            mapView.deselectAnnotation(annotation, animated: false)

            if let cluster = annotation as? MKClusterAnnotation {
                parent.onSelectCluster(cluster)
            } else if let dealAnnotation = annotation as? DealMapAnnotation {
                parent.onSelectAnnotation(dealAnnotation)
            }
        }

        func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
            MKClusterAnnotation(memberAnnotations: memberAnnotations)
        }
    }
}
