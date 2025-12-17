import Foundation
import SwiftUI
import SwiftData
import Combine
import ActivityKit

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
    private let activityService = ReadingActivityService.shared

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
    func checkForActiveSession(context: ModelContext) {
        if let activeSession = sessionService.fetchActiveSession(book: book, context: context) {
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
    }

    func startSession(context: ModelContext) {
        let newSession = sessionService.startSession(
            book: book,
            startPage: startPage > 0 ? startPage : nil,
            context: context
        )
        session = newSession
        isReading = true
        elapsedSeconds = 0
        totalPausedSeconds = 0
        startTimer()
        HapticService.shared.sessionStarted()

        // Start Live Activity
        activityService.startActivity(
            bookTitle: book.title,
            bookAuthor: book.author,
            startPage: startPage > 0 ? startPage : nil
        )
    }

    func pauseSession(context: ModelContext) {
        guard let currentSession = session else { return }

        sessionService.pauseSession(currentSession, context: context)
        stopTimer()
        isPaused = true
        isReading = false
        pauseStartTime = Date()
        HapticService.shared.sessionPaused()

        // Update Live Activity
        activityService.updateActivity(
            elapsedSeconds: elapsedSeconds,
            isPaused: true,
            currentPage: endPage > 0 ? endPage : nil
        )
    }

    func resumeSession(context: ModelContext) {
        guard let currentSession = session,
              let pauseStart = pauseStartTime else { return }

        let additionalPausedSeconds = Int(Date().timeIntervalSince(pauseStart))

        sessionService.resumeSession(currentSession, additionalPausedSeconds: additionalPausedSeconds, context: context)
        totalPausedSeconds += additionalPausedSeconds
        pauseStartTime = nil
        isPaused = false
        isReading = true
        startTimer()
        HapticService.shared.sessionResumed()

        // Update Live Activity
        activityService.updateActivity(
            elapsedSeconds: elapsedSeconds,
            isPaused: false,
            currentPage: endPage > 0 ? endPage : nil
        )
    }

    func endSession(context: ModelContext) -> Bool {
        guard let currentSession = session else { return false }

        // If paused, add remaining paused time
        if isPaused, let pauseStart = pauseStartTime {
            totalPausedSeconds += Int(Date().timeIntervalSince(pauseStart))
        }

        stopTimer()

        sessionService.endSession(
            currentSession,
            endPage: endPage > 0 ? endPage : nil,
            durationSeconds: elapsedSeconds,
            pagesRead: pagesRead > 0 ? pagesRead : nil,
            context: context
        )

        // Update current page on the book
        if endPage > 0 {
            bookService.updateCurrentPage(userBook: userBook, page: endPage, context: context)

            // Check if book is completed
            if let pageCount = book.pageCount, endPage >= pageCount {
                bookService.updateStatus(userBook: userBook, status: .completed, context: context)
                HapticService.shared.bookCompleted()
            } else {
                HapticService.shared.sessionEnded()
            }
        } else {
            HapticService.shared.sessionEnded()
        }

        // End Live Activity
        activityService.endActivity(showSummary: true)

        session = nil
        isReading = false
        isPaused = false

        return true
    }

    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.elapsedSeconds += 1

                // Update Live Activity every 10 seconds to save battery
                if self.elapsedSeconds % 10 == 0 {
                    self.activityService.updateActivity(
                        elapsedSeconds: self.elapsedSeconds,
                        isPaused: false,
                        currentPage: self.endPage > 0 ? self.endPage : nil
                    )
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Notes
    func addSessionNote(context: ModelContext) {
        guard !noteContent.trimmed.isEmpty else { return }

        let note = noteService.addNote(
            book: book,
            content: noteContent.trimmed,
            noteType: .note,
            pageNumber: nil,
            context: context
        )
        sessionNotes.append(note)
        noteContent = ""
    }

    func addScannedQuote(_ text: String, context: ModelContext) {
        guard !text.trimmed.isEmpty else { return }

        let note = noteService.addNote(
            book: book,
            content: text.trimmed,
            noteType: .quote,
            pageNumber: nil,
            context: context
        )
        sessionNotes.append(note)
    }

    func deleteNote(_ note: Note, context: ModelContext) {
        noteService.deleteNote(note, context: context)
        sessionNotes.removeAll { $0.id == note.id }
    }

    // MARK: - Cleanup
    func cleanup() {
        stopTimer()
        // Don't end activity on cleanup - user might come back
    }

    func clearError() {
        error = nil
    }
}
