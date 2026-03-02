import Foundation

/// Service for fetching venue photos from Supabase or mock data.
actor PhotoService {
    static let shared = PhotoService()

    private init() {}

    /// Fetch photos for a venue, sorted by `sort_order`.
    /// Falls back to mock Unsplash URLs if Supabase is unavailable.
    func fetchVenuePhotos(venueId: UUID) async throws -> [VenuePhoto] {
        // Attempt Supabase fetch
        if !SupabaseConfig.url.isEmpty, !SupabaseConfig.anonKey.isEmpty {
            do {
                return try await fetchFromSupabase(venueId: venueId)
            } catch {
                // Fall through to mock data
            }
        }
        return mockPhotos(for: venueId)
    }

    private func fetchFromSupabase(venueId: UUID) async throws -> [VenuePhoto] {
        guard let baseURL = URL(string: SupabaseConfig.url) else {
            throw PhotoServiceError.invalidConfiguration
        }

        var components = URLComponents(url: baseURL.appendingPathComponent("/rest/v1/venue_photos"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "venue_id", value: "eq.\(venueId.uuidString)"),
            URLQueryItem(name: "order", value: "sort_order.asc"),
            URLQueryItem(name: "select", value: "*")
        ]

        guard let url = components.url else {
            throw PhotoServiceError.invalidConfiguration
        }

        var request = URLRequest(url: url)
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw PhotoServiceError.fetchFailed
        }

        let decoder = JSONDecoder()
        return try decoder.decode([VenuePhoto].self, from: data)
    }

    // MARK: - Mock Data

    private func mockPhotos(for venueId: UUID) -> [VenuePhoto] {
        let unsplashPhotos: [(url: String, caption: String)] = [
            ("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800", "Main dining area"),
            ("https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=800", "Bar seating"),
            ("https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800", "Outdoor patio"),
            ("https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=800", "Cozy interior"),
            ("https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800", "Evening ambiance")
        ]

        return unsplashPhotos.enumerated().map { index, photo in
            VenuePhoto(
                id: UUID(),
                venueId: venueId,
                url: photo.url,
                caption: photo.caption,
                sortOrder: index
            )
        }
    }
}

enum PhotoServiceError: Error, LocalizedError {
    case invalidConfiguration
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration: return "Supabase configuration is invalid"
        case .fetchFailed: return "Failed to fetch venue photos"
        }
    }
}
