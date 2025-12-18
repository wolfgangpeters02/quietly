import Foundation
import SwiftData

@Model
final class ReadingSession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var durationSeconds: Int?
    var startPage: Int?
    var endPage: Int?
    var pagesRead: Int?
    var pausedAt: Date?
    var pausedDurationSeconds: Int?
    var createdAt: Date

    // Relationship to Book
    var book: Book?

    init(
        id: UUID = UUID(),
        book: Book? = nil,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        durationSeconds: Int? = nil,
        startPage: Int? = nil,
        endPage: Int? = nil,
        pagesRead: Int? = nil,
        pausedAt: Date? = nil,
        pausedDurationSeconds: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.book = book
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationSeconds = durationSeconds
        self.startPage = startPage
        self.endPage = endPage
        self.pagesRead = pagesRead
        self.pausedAt = pausedAt
        self.pausedDurationSeconds = pausedDurationSeconds
        self.createdAt = createdAt
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
