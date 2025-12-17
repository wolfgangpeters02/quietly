import Foundation

struct ReadingStats {
    var readingStreak: Int = 0
    var totalBooks: Int = 0
    var booksCompleted: Int = 0
    var booksReading: Int = 0
    var booksWantToRead: Int = 0
    var totalReadingMinutes: Int = 0
    var totalPagesRead: Int = 0
    var averagePagesPerMinute: Double = 0.0
    var totalSessions: Int = 0

    var formattedTotalTime: String {
        let hours = totalReadingMinutes / 60
        let minutes = totalReadingMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var streakLabel: String {
        readingStreak == 1 ? "day" : "days"
    }
}

// MARK: - Book Reading Stats
struct BookReadingStats {
    let totalSessions: Int
    let totalMinutes: Int
    let totalPagesRead: Int
    let averagePagesPerMinute: Double

    var formattedTotalTime: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }

    var formattedSpeed: String {
        if averagePagesPerMinute > 0 {
            return String(format: "%.1f pages/min", averagePagesPerMinute)
        }
        return "-"
    }
}
