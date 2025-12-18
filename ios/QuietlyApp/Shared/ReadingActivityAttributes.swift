import Foundation
import ActivityKit

/// Attributes for the Reading Session Live Activity
/// This file is shared between the main app and the Widget extension
struct ReadingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var isPaused: Bool
        var startPage: Int?
        var currentPage: Int?
        /// The effective start time for the live timer (accounts for pauses)
        var timerStartDate: Date

        var formattedTime: String {
            let hours = elapsedSeconds / 3600
            let minutes = (elapsedSeconds % 3600) / 60
            let seconds = elapsedSeconds % 60

            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            }
            return String(format: "%d:%02d", minutes, seconds)
        }

        var pagesRead: Int {
            guard let start = startPage, let current = currentPage else { return 0 }
            return max(0, current - start)
        }

        /// Timer interval for live counting
        var timerInterval: ClosedRange<Date> {
            timerStartDate...Date.distantFuture
        }
    }

    // Fixed attributes (set at activity start)
    var bookTitle: String
    var bookAuthor: String?
    var startTime: Date
}
