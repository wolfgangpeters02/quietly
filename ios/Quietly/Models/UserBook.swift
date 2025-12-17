import Foundation
import SwiftData

@Model
final class UserBook {
    @Attribute(.unique) var id: UUID
    var status: ReadingStatus
    var currentPage: Int?
    var rating: Int?
    var startedAt: Date?
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    // Relationship to Book
    var book: Book?

    init(
        id: UUID = UUID(),
        book: Book? = nil,
        status: ReadingStatus = .wantToRead,
        currentPage: Int? = nil,
        rating: Int? = nil,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.book = book
        self.status = status
        self.currentPage = currentPage
        self.rating = rating
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
