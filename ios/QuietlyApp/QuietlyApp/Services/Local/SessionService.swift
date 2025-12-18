import Foundation
import SwiftData

final class SessionService {
    // MARK: - Fetch Sessions for Book
    func fetchSessions(book: Book, context: ModelContext) -> [ReadingSession] {
        let bookId = book.id
        let descriptor = FetchDescriptor<ReadingSession>(
            predicate: #Predicate { $0.book?.id == bookId },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch sessions: \(error)")
            return []
        }
    }

    // MARK: - Fetch All Sessions
    func fetchAllSessions(context: ModelContext) -> [ReadingSession] {
        let descriptor = FetchDescriptor<ReadingSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch all sessions: \(error)")
            return []
        }
    }

    // MARK: - Fetch Active Session
    func fetchActiveSession(book: Book, context: ModelContext) -> ReadingSession? {
        let bookId = book.id
        let descriptor = FetchDescriptor<ReadingSession>(
            predicate: #Predicate { session in
                session.book?.id == bookId && session.endedAt == nil
            }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Failed to fetch active session: \(error)")
            return nil
        }
    }

    // MARK: - Start Session
    func startSession(book: Book, startPage: Int?, context: ModelContext) -> ReadingSession {
        let session = ReadingSession(
            book: book,
            startedAt: Date(),
            startPage: startPage
        )
        context.insert(session)
        return session
    }

    // MARK: - Pause Session
    func pauseSession(_ session: ReadingSession, context: ModelContext) {
        session.pausedAt = Date()
    }

    // MARK: - Resume Session
    func resumeSession(_ session: ReadingSession, additionalPausedSeconds: Int, context: ModelContext) {
        let newPausedDuration = (session.pausedDurationSeconds ?? 0) + additionalPausedSeconds
        session.pausedDurationSeconds = newPausedDuration
        session.pausedAt = nil
    }

    // MARK: - End Session
    func endSession(_ session: ReadingSession, endPage: Int?, durationSeconds: Int, pagesRead: Int?, context: ModelContext) {
        session.endedAt = Date()
        session.endPage = endPage
        session.durationSeconds = durationSeconds
        session.pagesRead = pagesRead
        session.pausedAt = nil
    }

    // MARK: - Delete Session
    func deleteSession(_ session: ReadingSession, context: ModelContext) {
        context.delete(session)
    }

    // MARK: - Calculate Reading Streak
    func calculateReadingStreak(context: ModelContext) -> Int {
        let sessions = fetchAllSessions(context: context)

        guard !sessions.isEmpty else { return 0 }

        // Group sessions by day
        let calendar = Calendar.current
        var datesWithReading = Set<Date>()

        for session in sessions {
            let day = calendar.startOfDay(for: session.startedAt)
            datesWithReading.insert(day)
        }

        // Calculate streak
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        // Check if user read today
        if datesWithReading.contains(currentDate) {
            streak = 1
        } else {
            // Check if user read yesterday (streak still valid)
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if !datesWithReading.contains(currentDate) {
                return 0
            }
            streak = 1
        }

        // Count consecutive days backwards
        while true {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if datesWithReading.contains(currentDate) {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Get Book Reading Stats
    func getBookStats(book: Book, context: ModelContext) -> BookReadingStats {
        let sessions = fetchSessions(book: book, context: context)

        let totalSeconds = sessions.compactMap { $0.durationSeconds }.reduce(0, +)
        let totalPages = sessions.compactMap { $0.pagesRead }.reduce(0, +)

        let avgPagesPerMinute: Double
        if totalSeconds > 0 && totalPages > 0 {
            avgPagesPerMinute = Double(totalPages) / (Double(totalSeconds) / 60.0)
        } else {
            avgPagesPerMinute = 0
        }

        return BookReadingStats(
            totalSessions: sessions.count,
            totalMinutes: totalSeconds / 60,
            totalPagesRead: totalPages,
            averagePagesPerMinute: avgPagesPerMinute
        )
    }

    // MARK: - Get Total Reading Minutes (for goals)
    func getTotalReadingMinutes(since date: Date, context: ModelContext) -> Int {
        let sessions = fetchAllSessions(context: context)

        let filteredSessions = sessions.filter { $0.startedAt >= date }
        let totalSeconds = filteredSessions.compactMap { $0.durationSeconds }.reduce(0, +)

        return totalSeconds / 60
    }

    // MARK: - Get Today's Reading Minutes
    func getTodayReadingMinutes(context: ModelContext) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return getTotalReadingMinutes(since: startOfDay, context: context)
    }
}
