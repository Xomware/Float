import XCTest
@testable import Float

final class PhotoServiceTests: XCTestCase {

    func testMockPhotosReturnsFivePhotos() async throws {
        let service = PhotoService.shared
        let photos = try await service.fetchVenuePhotos(venueId: UUID())
        XCTAssertEqual(photos.count, 5, "Mock should return 5 photos")
    }

    func testMockPhotosSortOrder() async throws {
        let service = PhotoService.shared
        let photos = try await service.fetchVenuePhotos(venueId: UUID())

        for (index, photo) in photos.enumerated() {
            XCTAssertEqual(photo.sortOrder, index, "Photo at index \(index) should have sortOrder \(index)")
        }
    }

    func testMockPhotosHaveValidURLs() async throws {
        let service = PhotoService.shared
        let photos = try await service.fetchVenuePhotos(venueId: UUID())

        for photo in photos {
            XCTAssertNotNil(URL(string: photo.url), "Photo URL should be valid: \(photo.url)")
            XCTAssertTrue(photo.url.contains("unsplash"), "Mock URLs should be from Unsplash")
        }
    }

    func testMockPhotosHaveCaptions() async throws {
        let service = PhotoService.shared
        let photos = try await service.fetchVenuePhotos(venueId: UUID())

        for photo in photos {
            XCTAssertNotNil(photo.caption, "Mock photos should have captions")
            XCTAssertFalse(photo.caption!.isEmpty, "Captions should not be empty")
        }
    }

    func testMockPhotosMatchVenueId() async throws {
        let venueId = UUID()
        let service = PhotoService.shared
        let photos = try await service.fetchVenuePhotos(venueId: venueId)

        for photo in photos {
            XCTAssertEqual(photo.venueId, venueId, "Photo venueId should match requested venueId")
        }
    }

    func testVenuePhotoCodable() throws {
        let photo = VenuePhoto(
            id: UUID(),
            venueId: UUID(),
            url: "https://example.com/photo.jpg",
            caption: "Test caption",
            sortOrder: 0
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(photo)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(VenuePhoto.self, from: data)

        XCTAssertEqual(decoded.id, photo.id)
        XCTAssertEqual(decoded.venueId, photo.venueId)
        XCTAssertEqual(decoded.url, photo.url)
        XCTAssertEqual(decoded.caption, photo.caption)
        XCTAssertEqual(decoded.sortOrder, photo.sortOrder)
    }

    func testVenuePhotoDecodesFromSnakeCase() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "venue_id": "550e8400-e29b-41d4-a716-446655440001",
            "url": "https://example.com/photo.jpg",
            "caption": "Test",
            "sort_order": 2
        }
        """.data(using: .utf8)!

        let photo = try JSONDecoder().decode(VenuePhoto.self, from: json)
        XCTAssertEqual(photo.sortOrder, 2)
        XCTAssertEqual(photo.venueId.uuidString, "550E8400-E29B-41D4-A716-446655440001")
    }
}
