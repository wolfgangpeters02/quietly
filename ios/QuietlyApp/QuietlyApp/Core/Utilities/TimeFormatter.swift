import Foundation

enum TimeFormatter {
    // MARK: - Timer Format (HH:MM:SS or MM:SS)
    static func formatTimer(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }

    // MARK: - Duration Format (e.g., "1h 30m" or "45m")
    static func formatDuration(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            }
            return "\(hours)h"
        }
        if minutes > 0 {
            return "\(minutes)m"
        }
        return "\(seconds)s"
    }

    // MARK: - Duration Format from Minutes
    static func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 {
            if mins > 0 {
                return "\(hours)h \(mins)m"
            }
            return "\(hours)h"
        }
        return "\(mins)m"
    }

    // MARK: - Short Duration (e.g., "1:30" for 1h 30m)
    static func formatShortDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60

        if hours > 0 {
            return String(format: "%d:%02d", hours, mins)
        }
        return "\(mins) min"
    }

    // MARK: - Elapsed Time Calculation
    static func calculateElapsedSeconds(from startDate: Date, pausedDuration: Int = 0) -> Int {
        let elapsed = Int(Date().timeIntervalSince(startDate))
        return max(0, elapsed - pausedDuration)
    }

    // MARK: - Time Components from String (HH:mm:ss)
    static func timeComponents(from timeString: String) -> DateComponents {
        let parts = timeString.split(separator: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            return DateComponents(hour: 20, minute: 0)
        }
        return DateComponents(hour: hour, minute: minute)
    }

    // MARK: - Time String from Components
    static func timeString(from components: DateComponents) -> String {
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return String(format: "%02d:%02d:00", hour, minute)
    }

    // MARK: - Format Time for Display (e.g., "8:00 PM")
    static func formatTimeForDisplay(_ timeString: String) -> String {
        let components = timeComponents(from: timeString)
        let calendar = Calendar.current

        guard let date = calendar.date(from: components) else {
            return "8:00 PM"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
