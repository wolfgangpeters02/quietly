import Foundation
import SwiftUI
import SwiftData

@MainActor
final class ReadingHistoryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var sessions: [ReadingSession] = []
    @Published var isLoading = false
    @Published var selectedTimeRange: TimeRange = .week

    // MARK: - Dependencies
    private let sessionService = SessionService()

    // MARK: - Time Range
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"

        var id: String { rawValue }

        var startDate: Date? {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: now)
            case .all:
                return nil
            }
        }
    }

    // MARK: - Computed Properties
    var filteredSessions: [ReadingSession] {
        guard let startDate = selectedTimeRange.startDate else {
            return sessions
        }
        return sessions.filter { $0.startedAt >= startDate }
    }

    var groupedSessions: [(date: Date, sessions: [ReadingSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSessions) { session in
            calendar.startOfDay(for: session.startedAt)
        }
        return grouped
            .map { (date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    var totalMinutes: Int {
        let seconds = filteredSessions.compactMap { $0.durationSeconds }.reduce(0, +)
        return seconds / 60
    }

    var totalPages: Int {
        filteredSessions.compactMap { $0.pagesRead }.reduce(0, +)
    }

    var totalSessions: Int {
        filteredSessions.count
    }

    var averageSessionLength: Int {
        guard totalSessions > 0 else { return 0 }
        return totalMinutes / totalSessions
    }

    // Weekly reading data for chart
    var weeklyData: [(day: String, minutes: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var data: [(day: String, minutes: Int)] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"

        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }

            let dayStart = calendar.startOfDay(for: date)
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { continue }

            let daySessions = sessions.filter { session in
                session.startedAt >= dayStart && session.startedAt < dayEnd
            }

            let totalSeconds = daySessions.compactMap { $0.durationSeconds }.reduce(0, +)
            let dayName = dateFormatter.string(from: date)
            data.append((day: dayName, minutes: totalSeconds / 60))
        }

        return data
    }

    // MARK: - Data Loading
    func loadData(context: ModelContext) {
        isLoading = true
        sessions = sessionService.fetchAllSessions(context: context)
        isLoading = false
    }

    func refresh(context: ModelContext) {
        loadData(context: context)
    }

    // MARK: - Delete Session
    func deleteSession(_ session: ReadingSession, context: ModelContext) {
        sessionService.deleteSession(session, context: context)
        sessions.removeAll { $0.id == session.id }
    }
}
