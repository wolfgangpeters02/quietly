import Foundation

struct Note: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let bookId: UUID
    let content: String
    let noteType: NoteType
    let pageNumber: Int?
    let createdAt: Date
    var updatedAt: Date

    // Joined book data (for Notes view)
    var book: Book?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case bookId = "book_id"
        case content
        case noteType = "note_type"
        case pageNumber = "page_number"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case book = "books"
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

// MARK: - Insert Model
struct NoteInsert: Codable {
    let userId: UUID
    let bookId: UUID
    let content: String
    let noteType: NoteType
    let pageNumber: Int?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case bookId = "book_id"
        case content
        case noteType = "note_type"
        case pageNumber = "page_number"
    }
}

// MARK: - Book Notes Group (for Notes view)
struct BookNotesGroup: Identifiable {
    let id: UUID
    let book: Book
    let notes: [Note]

    var noteCount: Int { notes.count }
}
