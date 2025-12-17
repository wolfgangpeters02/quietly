import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Request Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    // MARK: - Check Permission Status
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule Daily Reading Reminder
    func scheduleDailyReminder(at timeComponents: DateComponents, bookTitle: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Read"

        if let title = bookTitle {
            content.body = "Continue reading \"\(title)\""
        } else {
            content.body = "Take a moment to read today"
        }

        content.sound = .default
        content.badge = 1

        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily-reading-reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }

    // MARK: - Cancel Daily Reminder
    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-reading-reminder"])
    }

    // MARK: - Schedule Streak Reminder
    func scheduleStreakReminder(currentStreak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive!"
        content.body = "You're on a \(currentStreak)-day reading streak. Read today to keep it going!"
        content.sound = .default

        // Schedule for 8 PM if user hasn't read today
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "streak-reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    // MARK: - Send Goal Achievement Notification
    func sendGoalAchievementNotification(goalType: GoalType) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Achieved!"
        content.body = "Congratulations! You've reached your \(goalType.displayName.lowercased()) goal."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "goal-achievement-\(goalType.rawValue)",
            content: content,
            trigger: nil // Deliver immediately
        )

        notificationCenter.add(request)
    }

    // MARK: - Send Book Completion Notification
    func sendBookCompletionNotification(bookTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Book Completed!"
        content.body = "You've finished reading \"\(bookTitle)\". Great job!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "book-completion-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request)
    }

    // MARK: - Send Test Notification
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Notifications are working correctly!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request)
    }

    // MARK: - Cancel All Notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    // MARK: - Clear Badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Get Pending Notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }
}
