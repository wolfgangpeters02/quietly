import Foundation

/// Data structure for sharing reading stats with widgets
/// This is duplicated from the main app for widget target access
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

/// Widget-side data provider for reading shared app data
struct WidgetDataReader {
    private static let appGroupIdentifier = "group.com.quietly.app"
    private static let dataKey = "widgetReadingData"

    static func getReadingData() -> WidgetReadingData {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: dataKey),
              let readingData = try? JSONDecoder().decode(WidgetReadingData.self, from: data) else {
            return .empty
        }
        return readingData
    }
}
