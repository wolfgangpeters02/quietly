import Foundation
import SwiftUI

@MainActor
final class BookDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userBook: UserBook
    @Published var notes: [Note] = []
    @Published var bookStats: BookReadingStats?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showDeleteConfirmation = false
    @Published var showAddNote = false
    @Published var showScanText = false

    // Note input
    @Published var noteContent = ""
    @Published var notePageNumber = ""
    @Published var noteType: NoteType = .note

    // MARK: - Dependencies
    private let bookService = BookService()
    private let sessionService = SessionService()
    private let noteService = NoteService()

    // MARK: - Computed Properties
    var book: Book? {
        userBook.book
    }

    var progress: Double {
        userBook.progress
    }

    var progressText: String {
        guard let pageCount = book?.pageCount, pageCount > 0 else {
            return ""
        }
        let current = userBook.currentPage ?? 0
        return "\(current) / \(pageCount) pages"
    }

    // MARK: - Initialization
    init(userBook: UserBook) {
        self.userBook = userBook
    }

    // MARK: - Data Loading
    func loadData() async {
        isLoading = true

        do {
            guard let bookId = book?.id else { return }

            async let notesTask = noteService.fetchNotes(bookId: bookId)
            async let statsTask = sessionService.getBookStats(bookId: bookId)

            let (fetchedNotes, fetchedStats) = try await (notesTask, statsTask)

            notes = fetchedNotes
            bookStats = fetchedStats

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Status Actions
    func updateStatus(_ status: ReadingStatus) async {
        do {
            try await bookService.updateStatus(userBookId: userBook.id, status: status)
            userBook.status = status

            if status == .completed {
                NotificationService.shared.sendBookCompletionNotification(
                    bookTitle: book?.title ?? "your book"
                )
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Rating Actions
    func updateRating(_ rating: Int) async {
        do {
            try await bookService.updateRating(userBookId: userBook.id, rating: rating)
            userBook.rating = rating
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Note Actions
    func addNote() async {
        guard !noteContent.trimmed.isEmpty else { return }

        do {
            guard let bookId = book?.id else { return }

            let pageNum = Int(notePageNumber)
            let note = try await noteService.addNote(
                bookId: bookId,
                content: noteContent.trimmed,
                noteType: noteType,
                pageNumber: pageNum
            )

            notes.insert(note, at: 0)
            clearNoteForm()

        } catch {
            self.error = error.localizedDescription
        }
    }

    func addNoteFromScan(_ text: String) async {
        noteContent = text
        noteType = .quote
        await addNote()
    }

    func deleteNote(_ note: Note) async {
        do {
            try await noteService.deleteNote(noteId: note.id)
            notes.removeAll { $0.id == note.id }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Delete Book
    func removeFromLibrary() async -> Bool {
        do {
            try await bookService.removeFromLibrary(userBookId: userBook.id)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    // MARK: - Private Methods
    private func clearNoteForm() {
        noteContent = ""
        notePageNumber = ""
        noteType = .note
        showAddNote = false
    }

    func clearError() {
        error = nil
    }
}
