import Foundation
import Supabase

final class SessionService {
    private let client = SupabaseManager.shared.client

    // MARK: - Fetch Sessions for Book
    func fetchSessions(bookId: UUID) async throws -> [ReadingSession] {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [ReadingSession] = try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("book_id", value: bookId.uuidString)
            .order("started_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Fetch All Sessions
    func fetchAllSessions() async throws -> [ReadingSession] {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [ReadingSession] = try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .select("*, books(*)")
            .eq("user_id", value: userId.uuidString)
            .order("started_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Fetch Active Session
    func fetchActiveSession(bookId: UUID) async throws -> ReadingSession? {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [ReadingSession] = try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("book_id", value: bookId.uuidString)
            .is("ended_at", value: nil)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Start Session
    func startSession(bookId: UUID, startPage: Int?) async throws -> ReadingSession {
        let userId = try SupabaseManager.shared.requireUserId()

        let insert = ReadingSessionInsert(
            userId: userId,
            bookId: bookId,
            startedAt: Date(),
            startPage: startPage
        )

        let response: [ReadingSession] = try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .insert(insert)
            .select()
            .execute()
            .value

        guard let session = response.first else {
            throw SupabaseError.databaseError("Failed to create session")
        }

        return session
    }

    // MARK: - Pause Session
    func pauseSession(sessionId: UUID) async throws {
        try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .update(["paused_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: sessionId.uuidString)
            .execute()
    }

    // MARK: - Resume Session
    func resumeSession(sessionId: UUID, additionalPausedSeconds: Int) async throws {
        // Fetch current paused duration
        let sessions: [ReadingSession] = try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .select()
            .eq("id", value: sessionId.uuidString)
            .limit(1)
            .execute()
            .value

        guard let session = sessions.first else {
            throw SupabaseError.databaseError("Session not found")
        }

        let newPausedDuration = (session.pausedDurationSeconds ?? 0) + additionalPausedSeconds

        try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .update([
                "paused_at": nil as String?,
                "paused_duration_seconds": newPausedDuration
            ])
            .eq("id", value: sessionId.uuidString)
            .execute()
    }

    // MARK: - End Session
    func endSession(sessionId: UUID, endPage: Int?, durationSeconds: Int, pagesRead: Int?) async throws {
        var update = ReadingSessionUpdate()
        update.endedAt = Date()
        update.endPage = endPage
        update.durationSeconds = durationSeconds
        update.pagesRead = pagesRead
        update.pausedAt = nil

        try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .update(update)
            .eq("id", value: sessionId.uuidString)
            .execute()
    }

    // MARK: - Delete Session
    func deleteSession(sessionId: UUID) async throws {
        try await client.database
            .from(SupabaseTable.readingSessions.rawValue)
            .delete()
            .eq("id", value: sessionId.uuidString)
            .execute()
    }

    // MARK: - Calculate Reading Streak
    func calculateReadingStreak() async throws -> Int {
        let sessions = try await fetchAllSessions()

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
    func getBookStats(bookId: UUID) async throws -> BookReadingStats {
        let sessions = try await fetchSessions(bookId: bookId)

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
    func getTotalReadingMinutes(since date: Date) async throws -> Int {
        let sessions = try await fetchAllSessions()

        let filteredSessions = sessions.filter { $0.startedAt >= date }
        let totalSeconds = filteredSessions.compactMap { $0.durationSeconds }.reduce(0, +)

        return totalSeconds / 60
    }
}
