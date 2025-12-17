import Foundation
import SwiftUI
import Combine

@MainActor
final class ReadingSessionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var session: ReadingSession?
    @Published var elapsedSeconds: Int = 0
    @Published var isReading = false
    @Published var isPaused = false
    @Published var startPage: Int = 0
    @Published var error: String?
    @Published var showEndDialog = false

    // Session notes
    @Published var sessionNotes: [Note] = []
    @Published var noteContent = ""

    // End session
    @Published var endPage: Int = 0

    // MARK: - Properties
    let book: Book
    let userBook: UserBook

    // MARK: - Private Properties
    private var timer: Timer?
    private var pauseStartTime: Date?
    private var totalPausedSeconds: Int = 0
    private let sessionService = SessionService()
    private let noteService = NoteService()
    private let bookService = BookService()

    // MARK: - Computed Properties
    var formattedTime: String {
        TimeFormatter.formatTimer(seconds: elapsedSeconds)
    }

    var canStart: Bool {
        session == nil
    }

    var pagesRead: Int {
        max(0, endPage - startPage)
    }

    // MARK: - Initialization
    init(book: Book, userBook: UserBook) {
        self.book = book
        self.userBook = userBook
        self.startPage = userBook.currentPage ?? 0
        self.endPage = userBook.currentPage ?? 0
    }

    // MARK: - Session Lifecycle
    func checkForActiveSession() async {
        do {
            if let activeSession = try await sessionService.fetchActiveSession(bookId: book.id) {
                session = activeSession
                startPage = activeSession.startPage ?? 0
                totalPausedSeconds = activeSession.pausedDurationSeconds ?? 0

                // Calculate elapsed time
                let elapsed = TimeFormatter.calculateElapsedSeconds(
                    from: activeSession.startedAt,
                    pausedDuration: totalPausedSeconds
                )
                elapsedSeconds = elapsed

                if activeSession.isPaused {
                    isPaused = true
                    pauseStartTime = activeSession.pausedAt
                } else {
                    isReading = true
                    startTimer()
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func startSession() async {
        do {
            let newSession = try await sessionService.startSession(
                bookId: book.id,
                startPage: startPage > 0 ? startPage : nil
            )
            session = newSession
            isReading = true
            elapsedSeconds = 0
            totalPausedSeconds = 0
            startTimer()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func pauseSession() async {
        guard let sessionId = session?.id else { return }

        do {
            try await sessionService.pauseSession(sessionId: sessionId)
            stopTimer()
            isPaused = true
            isReading = false
            pauseStartTime = Date()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func resumeSession() async {
        guard let sessionId = session?.id,
              let pauseStart = pauseStartTime else { return }

        let additionalPausedSeconds = Int(Date().timeIntervalSince(pauseStart))

        do {
            try await sessionService.resumeSession(
                sessionId: sessionId,
                additionalPausedSeconds: additionalPausedSeconds
            )
            totalPausedSeconds += additionalPausedSeconds
            pauseStartTime = nil
            isPaused = false
            isReading = true
            startTimer()
        } catch {
            self.error = error.localizedDescription
        }
    }

    func endSession() async -> Bool {
        guard let sessionId = session?.id else { return false }

        // If paused, add remaining paused time
        if isPaused, let pauseStart = pauseStartTime {
            totalPausedSeconds += Int(Date().timeIntervalSince(pauseStart))
        }

        do {
            stopTimer()

            try await sessionService.endSession(
                sessionId: sessionId,
                endPage: endPage > 0 ? endPage : nil,
                durationSeconds: elapsedSeconds,
                pagesRead: pagesRead > 0 ? pagesRead : nil
            )

            // Update current page on the book
            if endPage > 0 {
                try await bookService.updateCurrentPage(
                    userBookId: userBook.id,
                    page: endPage
                )

                // Check if book is completed
                if let pageCount = book.pageCount, endPage >= pageCount {
                    try await bookService.updateStatus(
                        userBookId: userBook.id,
                        status: .completed
                    )
                }
            }

            session = nil
            isReading = false
            isPaused = false

            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Notes
    func addSessionNote() async {
        guard !noteContent.trimmed.isEmpty else { return }

        do {
            let note = try await noteService.addNote(
                bookId: book.id,
                content: noteContent.trimmed,
                noteType: .note,
                pageNumber: nil
            )
            sessionNotes.append(note)
            noteContent = ""
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteNote(_ note: Note) async {
        do {
            try await noteService.deleteNote(noteId: note.id)
            sessionNotes.removeAll { $0.id == note.id }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Cleanup
    func cleanup() {
        stopTimer()
    }

    func clearError() {
        error = nil
    }
}
