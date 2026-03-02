import Foundation

struct VenuePhoto: Identifiable, Codable {
    let id: UUID
    let venueId: UUID
    let url: String
    let caption: String?
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case venueId = "venue_id"
        case url
        case caption
        case sortOrder = "sort_order"
    }
}
