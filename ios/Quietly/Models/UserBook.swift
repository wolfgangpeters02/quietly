import Foundation

struct UserBook: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let bookId: UUID
    var status: ReadingStatus
    var currentPage: Int?
    var rating: Int?
    var startedAt: Date?
    var completedAt: Date?
    let createdAt: Date
    var updatedAt: Date

    // Joined book data
    var book: Book?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case bookId = "book_id"
        case status
        case currentPage = "current_page"
        case rating
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case book = "books"
    }

    // Computed properties
    var progress: Double {
        guard let pageCount = book?.pageCount, pageCount > 0,
              let current = currentPage else { return 0 }
        return min(Double(current) / Double(pageCount), 1.0)
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    var isReading: Bool {
        status == .reading
    }

    var isCompleted: Bool {
        status == .completed
    }
}

// MARK: - Insert Model
struct UserBookInsert: Codable {
    let userId: UUID
    let bookId: UUID
    let status: ReadingStatus
    let currentPage: Int?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case bookId = "book_id"
        case status
        case currentPage = "current_page"
    }
}

// MARK: - Update Model
struct UserBookUpdate: Codable {
    var status: ReadingStatus?
    var currentPage: Int?
    var rating: Int?
    var startedAt: Date?
    var completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case status
        case currentPage = "current_page"
        case rating
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}
