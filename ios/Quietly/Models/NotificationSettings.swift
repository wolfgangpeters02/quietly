import Foundation

struct NotificationSettings: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var dailyReminderEnabled: Bool
    var reminderTime: String // "HH:mm:ss" format
    var goalNotifications: Bool
    var streakNotifications: Bool
    var completionNotifications: Bool
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case dailyReminderEnabled = "daily_reminder_enabled"
        case reminderTime = "reminder_time"
        case goalNotifications = "goal_notifications"
        case streakNotifications = "streak_notifications"
        case completionNotifications = "completion_notifications"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var reminderTimeComponents: DateComponents {
        let parts = reminderTime.split(separator: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            return DateComponents(hour: 20, minute: 0) // Default 8pm
        }
        return DateComponents(hour: hour, minute: minute)
    }

    var reminderTimeFormatted: String {
        let components = reminderTimeComponents
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return "8:00 PM"
    }
}

// MARK: - Update Model
struct NotificationSettingsUpdate: Codable {
    var dailyReminderEnabled: Bool?
    var reminderTime: String?
    var goalNotifications: Bool?
    var streakNotifications: Bool?
    var completionNotifications: Bool?

    enum CodingKeys: String, CodingKey {
        case dailyReminderEnabled = "daily_reminder_enabled"
        case reminderTime = "reminder_time"
        case goalNotifications = "goal_notifications"
        case streakNotifications = "streak_notifications"
        case completionNotifications = "completion_notifications"
    }
}
