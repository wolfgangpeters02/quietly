import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    var fullName: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case createdAt = "created_at"
    }
}
