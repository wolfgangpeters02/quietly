import Foundation
import WidgetKit

/// Data structure for sharing reading stats with widgets
struct WidgetReadingData: Codable {
    var currentBookTitle: String?
    var currentBookAuthor: String?
    var currentBookProgress: Double
    var currentBookCoverUrl: String?
    var todayReadingMinutes: Int
    var currentStreak: Int
    var dailyGoalMinutes: Int
    var dailyGoalProgress: Double
    var booksCompletedThisYear: Int
    var lastUpdated: Date

    static var empty: WidgetReadingData {
        WidgetReadingData(
            currentBookTitle: nil,
            currentBookAuthor: nil,
            currentBookProgress: 0,
            currentBookCoverUrl: nil,
            todayReadingMinutes: 0,
            currentStreak: 0,
            dailyGoalMinutes: 30,
            dailyGoalProgress: 0,
            booksCompletedThisYear: 0,
            lastUpdated: Date()
        )
    }
}

/// Service for sharing data between the main app and widgets
final class WidgetDataProvider {
    static let shared = WidgetDataProvider()

    private let appGroupIdentifier = "group.com.quietly.app"
    private let dataKey = "widgetReadingData"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    private init() {}

    // MARK: - Read Data

    /// Retrieves the current widget data
    func getReadingData() -> WidgetReadingData {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: dataKey),
              let readingData = try? JSONDecoder().decode(WidgetReadingData.self, from: data) else {
            return .empty
        }
        return readingData
    }

    // MARK: - Write Data

    /// Updates widget data - call this when reading stats change
    func updateReadingData(_ data: WidgetReadingData) {
        guard let defaults = sharedDefaults,
              let encoded = try? JSONEncoder().encode(data) else { return }

        defaults.set(encoded, forKey: dataKey)

        // Reload widgets
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Updates the currently reading book info
    func updateCurrentBook(
        title: String?,
        author: String?,
        progress: Double,
        coverUrl: String?
    ) {
        var data = getReadingData()
        data.currentBookTitle = title
        data.currentBookAuthor = author
        data.currentBookProgress = progress
        data.currentBookCoverUrl = coverUrl
        data.lastUpdated = Date()
        updateReadingData(data)
    }

    /// Updates today's reading minutes
    func updateTodayMinutes(_ minutes: Int) {
        var data = getReadingData()
        data.todayReadingMinutes = minutes
        data.lastUpdated = Date()

        // Update goal progress if there's a daily goal
        if data.dailyGoalMinutes > 0 {
            data.dailyGoalProgress = min(1.0, Double(minutes) / Double(data.dailyGoalMinutes))
        }

        updateReadingData(data)
    }

    /// Updates the reading streak
    func updateStreak(_ days: Int) {
        var data = getReadingData()
        data.currentStreak = days
        data.lastUpdated = Date()
        updateReadingData(data)
    }

    /// Updates daily goal configuration
    func updateDailyGoal(targetMinutes: Int) {
        var data = getReadingData()
        data.dailyGoalMinutes = targetMinutes
        data.lastUpdated = Date()
        updateReadingData(data)
    }

    /// Updates books completed this year
    func updateBooksCompleted(_ count: Int) {
        var data = getReadingData()
        data.booksCompletedThisYear = count
        data.lastUpdated = Date()
        updateReadingData(data)
    }

    /// Comprehensive update with all data
    func updateAllData(
        currentBook: (title: String?, author: String?, progress: Double, coverUrl: String?)?,
        todayMinutes: Int,
        streak: Int,
        dailyGoalMinutes: Int,
        booksCompletedThisYear: Int
    ) {
        var data = WidgetReadingData(
            currentBookTitle: currentBook?.title,
            currentBookAuthor: currentBook?.author,
            currentBookProgress: currentBook?.progress ?? 0,
            currentBookCoverUrl: currentBook?.coverUrl,
            todayReadingMinutes: todayMinutes,
            currentStreak: streak,
            dailyGoalMinutes: dailyGoalMinutes,
            dailyGoalProgress: dailyGoalMinutes > 0 ? min(1.0, Double(todayMinutes) / Double(dailyGoalMinutes)) : 0,
            booksCompletedThisYear: booksCompletedThisYear,
            lastUpdated: Date()
        )
        updateReadingData(data)
    }
}
