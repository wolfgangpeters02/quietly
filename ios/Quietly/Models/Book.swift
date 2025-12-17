import Foundation
import SwiftData

@Model
final class Book {
    @Attribute(.unique) var id: UUID
    var isbn: String?
    var title: String
    var author: String?
    var coverUrl: String?
    var publisher: String?
    var publishedDate: String?
    var bookDescription: String?
    var pageCount: Int?
    var manualEntry: Bool
    var createdAt: Date

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \UserBook.book)
    var userBooks: [UserBook] = []

    @Relationship(deleteRule: .cascade, inverse: \Note.book)
    var notes: [Note] = []

    @Relationship(deleteRule: .cascade, inverse: \ReadingSession.book)
    var sessions: [ReadingSession] = []

    init(
        id: UUID = UUID(),
        isbn: String? = nil,
        title: String,
        author: String? = nil,
        coverUrl: String? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        bookDescription: String? = nil,
        pageCount: Int? = nil,
        manualEntry: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.coverUrl = coverUrl
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.bookDescription = bookDescription
        self.pageCount = pageCount
        self.manualEntry = manualEntry
        self.createdAt = createdAt
    }
}
