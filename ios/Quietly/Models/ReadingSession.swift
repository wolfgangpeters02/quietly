import Foundation

struct ReadingSession: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let bookId: UUID
    let startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int?
    var startPage: Int?
    var endPage: Int?
    var pagesRead: Int?
    var pausedAt: Date?
    var pausedDurationSeconds: Int?
    let createdAt: Date

    // Joined book data (optional)
    var book: Book?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case bookId = "book_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case startPage = "start_page"
        case endPage = "end_page"
        case pagesRead = "pages_read"
        case pausedAt = "paused_at"
        case pausedDurationSeconds = "paused_duration_seconds"
        case createdAt = "created_at"
        case book = "books"
    }

    // Computed properties
    var isActive: Bool {
        endedAt == nil
    }

    var isPaused: Bool {
        pausedAt != nil
    }

    var formattedDuration: String {
        guard let seconds = durationSeconds else { return "0:00" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    var pagesPerMinute: Double? {
        guard let pages = pagesRead, pages > 0,
              let seconds = durationSeconds, seconds > 0 else { return nil }
        let minutes = Double(seconds) / 60.0
        return Double(pages) / minutes
    }
}

// MARK: - Insert Model
struct ReadingSessionInsert: Codable {
    let userId: UUID
    let bookId: UUID
    let startedAt: Date
    let startPage: Int?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case bookId = "book_id"
        case startedAt = "started_at"
        case startPage = "start_page"
    }
}

// MARK: - Update Model
struct ReadingSessionUpdate: Codable {
    var endedAt: Date?
    var durationSeconds: Int?
    var startPage: Int?
    var endPage: Int?
    var pagesRead: Int?
    var pausedAt: Date?
    var pausedDurationSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case endedAt = "ended_at"
        case durationSeconds = "duration_seconds"
        case startPage = "start_page"
        case endPage = "end_page"
        case pagesRead = "pages_read"
        case pausedAt = "paused_at"
        case pausedDurationSeconds = "paused_duration_seconds"
    }
}
