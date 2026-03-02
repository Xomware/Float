// GeofenceManager.swift
// Float

import CoreLocation
import OSLog
import Supabase

private let logger = Logger(subsystem: "com.xomware.float", category: "Geofence")

// MARK: - GeofenceManager

/// Manages CLLocationManager geofences for Float venues.
/// Monitors regions around venues that have active deals.
/// When a user enters a geofence region, a local push notification is delivered.
///
/// Usage:
/// ```swift
/// GeofenceManager.shared.startMonitoring(venues: activeVenues)
/// ```
@MainActor
final class GeofenceManager: NSObject, ObservableObject {

    // MARK: - Constants
    static let geofenceRadius: CLLocationDistance = 200 // metres
    static let maxMonitoredRegions = 20 // CoreLocation limit is 20

    // MARK: - Singleton
    static let shared = GeofenceManager()

    // MARK: - Published State
    @Published var monitoredVenueIds: Set<String> = []
    @Published var locationAuthStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Private
    private let manager: CLLocationManager
    private let notificationService = NotificationService.shared
    private let supabase = SupabaseClientService.shared.client

    // Tracks venue metadata keyed by region identifier for notification delivery
    private var venueRegionMap: [String: VenueGeofenceInfo] = [:]

    override private init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - Public API

    /// Requests "always" authorization (required for background geofence monitoring).
    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    /// Starts monitoring geofences for the given venues.
    /// Only venues with active deals are added. Prioritizes featured venues.
    func startMonitoring(venues: [VenueGeofenceInfo]) {
        // Remove stale regions not in new venue set
        let newIds = Set(venues.map(\.venueId))
        for region in manager.monitoredRegions where region.identifier.hasPrefix("float-venue-") {
            let venueId = String(region.identifier.dropFirst("float-venue-".count))
            if !newIds.contains(venueId) {
                manager.stopMonitoring(for: region)
                monitoredVenueIds.remove(venueId)
                venueRegionMap.removeValue(forKey: region.identifier)
                logger.debug("Stopped monitoring venue: \(venueId)")
            }
        }

        // Add new venues (up to system limit)
        let toAdd = venues.prefix(Self.maxMonitoredRegions)
        for info in toAdd {
            let identifier = "float-venue-\(info.venueId)"
            guard !monitoredVenueIds.contains(info.venueId) else { continue }

            let center = CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude)
            let region = CLCircularRegion(
                center: center,
                radius: Self.geofenceRadius,
                identifier: identifier
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false

            manager.startMonitoring(for: region)
            monitoredVenueIds.insert(info.venueId)
            venueRegionMap[identifier] = info
            logger.info("Monitoring geofence for venue: \(info.venueName) (\(info.venueId))")
        }
    }

    /// Stops all Float geofence monitoring.
    func stopAllMonitoring() {
        for region in manager.monitoredRegions where region.identifier.hasPrefix("float-venue-") {
            manager.stopMonitoring(for: region)
        }
        monitoredVenueIds.removeAll()
        venueRegionMap.removeAll()
        logger.info("Stopped all geofence monitoring")
    }

    // MARK: - Background Refresh

    /// Refreshes the geofenced venues from Supabase (called from background fetch handler).
    func refreshGeofences(for userId: String) async {
        do {
            struct VenueRow: Decodable {
                let id: String
                let name: String
                let latitude: Double
                let longitude: Double
                let deals: [DealRow]

                enum CodingKeys: String, CodingKey {
                    case id, name, latitude, longitude
                    case deals
                }

                struct DealRow: Decodable {
                    let id: String
                    let title: String
                    let expiresAt: String

                    enum CodingKeys: String, CodingKey {
                        case id, title
                        case expiresAt = "expires_at"
                    }
                }
            }

            // Fetch venues with active deals (for geofencing)
            let rows: [VenueRow] = try await supabase
                .from("venues")
                .select("id, name, latitude, longitude, deals!inner(id, title, expires_at)")
                .eq("deals.is_active", value: true)
                .gt("deals.expires_at", value: ISO8601DateFormatter().string(from: Date()))
                .limit(Self.maxMonitoredRegions)
                .execute()
                .value

            let infos = rows.compactMap { row -> VenueGeofenceInfo? in
                guard let deal = row.deals.first else { return nil }
                return VenueGeofenceInfo(
                    venueId: row.id,
                    venueName: row.name,
                    latitude: row.latitude,
                    longitude: row.longitude,
                    activeDealId: deal.id,
                    activeDealTitle: deal.title
                )
            }

            startMonitoring(venues: infos)
            logger.info("Geofences refreshed: \(infos.count) venues")
        } catch {
            logger.error("Failed to refresh geofences: \(error)")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension GeofenceManager: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier.hasPrefix("float-venue-") else { return }

        Task { @MainActor in
            guard let info = self.venueRegionMap[region.identifier] else { return }
            logger.info("Entered geofence for venue: \(info.venueName)")

            await self.notificationService.scheduleNearbyDealAlert(
                venueId: info.venueId,
                venueName: info.venueName,
                dealId: info.activeDealId,
                dealTitle: info.activeDealTitle
            )
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        logger.debug("Exited region: \(region.identifier)")
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("Location manager failed: \(error)")
    }

    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        logger.error("Region monitoring failed for \(region?.identifier ?? "unknown"): \(error)")
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.locationAuthStatus = manager.authorizationStatus
            logger.info("Location auth changed: \(manager.authorizationStatus.rawValue)")
        }
    }
}

// MARK: - Supporting Types

/// Lightweight venue data for geofence setup
struct VenueGeofenceInfo {
    let venueId: String
    let venueName: String
    let latitude: Double
    let longitude: Double
    let activeDealId: String
    let activeDealTitle: String
}
