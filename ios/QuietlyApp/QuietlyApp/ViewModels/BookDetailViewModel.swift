import Foundation
import SwiftUI
import SwiftData

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
    func loadData(context: ModelContext) {
        isLoading = true

        guard let book = book else {
            isLoading = false
            return
        }

        notes = noteService.fetchNotes(book: book, context: context)
        bookStats = sessionService.getBookStats(book: book, context: context)

        isLoading = false
    }

    // MARK: - Status Actions
    func updateStatus(_ status: ReadingStatus, context: ModelContext) {
        bookService.updateStatus(userBook: userBook, status: status, context: context)
        userBook.status = status

        if status == .completed {
            NotificationService.shared.sendBookCompletionNotification(
                bookTitle: book?.title ?? "your book"
            )
            HapticService.shared.bookCompleted()
        } else {
            HapticService.shared.selectionChanged()
        }
    }

    // MARK: - Rating Actions
    func updateRating(_ rating: Int, context: ModelContext) {
        bookService.updateRating(userBook: userBook, rating: rating, context: context)
        userBook.rating = rating
    }

    // MARK: - Note Actions
    func addNote(context: ModelContext) {
        guard !noteContent.trimmed.isEmpty else { return }
        guard let book = book else { return }

        let pageNum = Int(notePageNumber)
        let note = noteService.addNote(
            book: book,
            content: noteContent.trimmed,
            noteType: noteType,
            pageNumber: pageNum,
            context: context
        )

        notes.insert(note, at: 0)
        clearNoteForm()
    }

    func addNoteFromScan(_ text: String, context: ModelContext) {
        noteContent = text
        noteType = .note
        addNote(context: context)
    }

    func deleteNote(_ note: Note, context: ModelContext) {
        noteService.deleteNote(note, context: context)
        notes.removeAll { $0.id == note.id }
        HapticService.shared.deleted()
    }

    // MARK: - Delete Book
    func removeFromLibrary(context: ModelContext) -> Bool {
        bookService.removeFromLibrary(userBook: userBook, context: context)
        HapticService.shared.deleted()
        return true
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
