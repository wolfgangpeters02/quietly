import Foundation
import Supabase

final class NoteService {
    private let client = SupabaseManager.shared.client

    // MARK: - Fetch Notes for Book
    func fetchNotes(bookId: UUID) async throws -> [Note] {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [Note] = try await client.database
            .from(SupabaseTable.notes.rawValue)
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("book_id", value: bookId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Fetch All Notes (with books)
    func fetchAllNotes() async throws -> [Note] {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [Note] = try await client.database
            .from(SupabaseTable.notes.rawValue)
            .select("*, books(*)")
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Add Note
    func addNote(
        bookId: UUID,
        content: String,
        noteType: NoteType = .note,
        pageNumber: Int? = nil
    ) async throws -> Note {
        let userId = try SupabaseManager.shared.requireUserId()

        let insert = NoteInsert(
            userId: userId,
            bookId: bookId,
            content: content,
            noteType: noteType,
            pageNumber: pageNumber
        )

        let response: [Note] = try await client.database
            .from(SupabaseTable.notes.rawValue)
            .insert(insert)
            .select()
            .execute()
            .value

        guard let note = response.first else {
            throw SupabaseError.databaseError("Failed to create note")
        }

        return note
    }

    // MARK: - Update Note
    func updateNote(noteId: UUID, content: String, pageNumber: Int?) async throws {
        try await client.database
            .from(SupabaseTable.notes.rawValue)
            .update([
                "content": content,
                "page_number": pageNumber as Any
            ])
            .eq("id", value: noteId.uuidString)
            .execute()
    }

    // MARK: - Delete Note
    func deleteNote(noteId: UUID) async throws {
        try await client.database
            .from(SupabaseTable.notes.rawValue)
            .delete()
            .eq("id", value: noteId.uuidString)
            .execute()
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
        let grouped = Dictionary(grouping: notes) { $0.bookId }

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
