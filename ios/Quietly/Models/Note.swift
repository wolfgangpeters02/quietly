import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var content: String
    var noteType: NoteType
    var pageNumber: Int?
    var createdAt: Date
    var updatedAt: Date

    // Relationship to Book
    var book: Book?

    init(
        id: UUID = UUID(),
        book: Book? = nil,
        content: String,
        noteType: NoteType = .note,
        pageNumber: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.book = book
        self.content = content
        self.noteType = noteType
        self.pageNumber = pageNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    var pageLabel: String? {
        guard let page = pageNumber else { return nil }
        return "p. \(page)"
    }
}

// MARK: - Book Notes Group (for Notes view)
struct BookNotesGroup: Identifiable {
    let id: UUID
    let book: Book
    let notes: [Note]

    var noteCount: Int { notes.count }
}
