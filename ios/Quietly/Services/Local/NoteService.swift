import Foundation
import SwiftData

final class NoteService {
    // MARK: - Fetch Notes for Book
    func fetchNotes(book: Book, context: ModelContext) -> [Note] {
        let bookId = book.id
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.book?.id == bookId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch notes: \(error)")
            return []
        }
    }

    // MARK: - Fetch All Notes
    func fetchAllNotes(context: ModelContext) -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch all notes: \(error)")
            return []
        }
    }

    // MARK: - Add Note
    func addNote(
        book: Book,
        content: String,
        noteType: NoteType = .note,
        pageNumber: Int? = nil,
        context: ModelContext
    ) -> Note {
        let note = Note(
            book: book,
            content: content,
            noteType: noteType,
            pageNumber: pageNumber
        )
        context.insert(note)
        return note
    }

    // MARK: - Update Note
    func updateNote(_ note: Note, content: String, pageNumber: Int?, context: ModelContext) {
        note.content = content
        note.pageNumber = pageNumber
        note.updatedAt = Date()
    }

    // MARK: - Delete Note
    func deleteNote(_ note: Note, context: ModelContext) {
        context.delete(note)
    }

    // MARK: - Search Notes
    func searchNotes(_ query: String, in notes: [Note]) -> [Note] {
        let lowercasedQuery = query.lowercased()
        return notes.filter { note in
            note.content.lowercased().contains(lowercasedQuery) ||
            (note.book?.title.lowercased().contains(lowercasedQuery) ?? false) ||
            (note.book?.author?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }

    // MARK: - Group Notes by Book
    func groupNotesByBook(_ notes: [Note]) -> [BookNotesGroup] {
        let grouped = Dictionary(grouping: notes) { $0.book?.id ?? UUID() }

        return grouped.compactMap { (bookId, bookNotes) -> BookNotesGroup? in
            guard let book = bookNotes.first?.book else { return nil }
            return BookNotesGroup(
                id: bookId,
                book: book,
                notes: bookNotes.sorted { $0.createdAt > $1.createdAt }
            )
        }.sorted { $0.notes.first?.createdAt ?? Date.distantPast > $1.notes.first?.createdAt ?? Date.distantPast }
    }
}
