import Foundation
import UserNotifications
import UIKit

// MARK: - Notification Categories & Actions

enum NotificationCategory: String {
    case readingReminder = "READING_REMINDER"
    case streakReminder = "STREAK_REMINDER"
    case goalAchievement = "GOAL_ACHIEVEMENT"
    case bookCompletion = "BOOK_COMPLETION"
}

enum NotificationAction: String {
    case startReading = "START_READING"
    case remindLater = "REMIND_LATER"
    case viewProgress = "VIEW_PROGRESS"
    case dismiss = "DISMISS"
}

final class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        registerCategories()
    }

    // MARK: - Register Categories with Actions
    private func registerCategories() {
        // Reading Reminder Actions
        let startReadingAction = UNNotificationAction(
            identifier: NotificationAction.startReading.rawValue,
            title: "Start Reading",
            options: [.foreground]
        )

        let remindLaterAction = UNNotificationAction(
            identifier: NotificationAction.remindLater.rawValue,
            title: "Remind in 1 hour",
            options: []
        )

        let viewProgressAction = UNNotificationAction(
            identifier: NotificationAction.viewProgress.rawValue,
            title: "View Progress",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: NotificationAction.dismiss.rawValue,
            title: "Dismiss",
            options: [.destructive]
        )

        // Reading Reminder Category
        let readingReminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.readingReminder.rawValue,
            actions: [startReadingAction, remindLaterAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        // Streak Reminder Category
        let streakReminderCategory = UNNotificationCategory(
            identifier: NotificationCategory.streakReminder.rawValue,
            actions: [startReadingAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        // Goal Achievement Category
        let goalAchievementCategory = UNNotificationCategory(
            identifier: NotificationCategory.goalAchievement.rawValue,
            actions: [viewProgressAction],
            intentIdentifiers: [],
            options: []
        )

        // Book Completion Category
        let bookCompletionCategory = UNNotificationCategory(
            identifier: NotificationCategory.bookCompletion.rawValue,
            actions: [viewProgressAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([
            readingReminderCategory,
            streakReminderCategory,
            goalAchievementCategory,
            bookCompletionCategory
        ])
    }

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
    func scheduleDailyReminder(at timeComponents: DateComponents, bookTitle: String? = nil, bookCoverUrl: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Read"

        if let title = bookTitle {
            content.body = "Continue reading \"\(title)\""
            content.subtitle = "Pick up where you left off"
        } else {
            content.body = "Take a moment to read today"
            content.subtitle = "Your reading streak awaits"
        }

        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.readingReminder.rawValue

        // Add user info for deep linking
        content.userInfo = [
            "action": "open_reading_session",
            "bookTitle": bookTitle ?? ""
        ]

        // Add interruption level for iOS 15+
        content.interruptionLevel = .timeSensitive

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
        content.title = "Keep Your Streak Alive"

        if currentStreak >= 7 {
            content.body = "Amazing! You're on a \(currentStreak)-day reading streak. Don't break it now!"
            content.subtitle = "You're on fire!"
        } else {
            content.body = "You're on a \(currentStreak)-day reading streak. Read today to keep it going!"
            content.subtitle = "Just a few minutes count"
        }

        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationCategory.streakReminder.rawValue
        content.interruptionLevel = .timeSensitive

        content.userInfo = [
            "action": "open_reading_session",
            "streakCount": currentStreak
        ]

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
    func sendGoalAchievementNotification(goalType: GoalType, currentValue: Int? = nil, targetValue: Int? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Achieved"
        content.subtitle = goalType.displayName

        switch goalType {
        case .dailyMinutes:
            content.body = "You've completed your daily reading goal! Keep up the great work."
        case .weeklyMinutes:
            content.body = "You've hit your weekly reading target! Fantastic dedication."
        case .booksPerMonth:
            content.body = "Another book finished this month! You're on a roll."
        case .booksPerYear:
            content.body = "You've reached your yearly book goal! What an accomplishment!"
        }

        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationCategory.goalAchievement.rawValue
        content.interruptionLevel = .active

        content.userInfo = [
            "action": "view_goals",
            "goalType": goalType.rawValue
        ]

        let request = UNNotificationRequest(
            identifier: "goal-achievement-\(goalType.rawValue)",
            content: content,
            trigger: nil // Deliver immediately
        )

        notificationCenter.add(request)
    }

    // MARK: - Send Book Completion Notification
    func sendBookCompletionNotification(bookTitle: String, totalBooks: Int? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Book Completed"
        content.subtitle = bookTitle

        if let total = totalBooks {
            content.body = "Congratulations on finishing your \(ordinal(total)) book! What will you read next?"
        } else {
            content.body = "Congratulations on finishing \"\(bookTitle)\"! What will you read next?"
        }

        content.sound = UNNotificationSound.default
        content.categoryIdentifier = NotificationCategory.bookCompletion.rawValue
        content.interruptionLevel = .active

        content.userInfo = [
            "action": "view_library",
            "bookTitle": bookTitle
        ]

        let request = UNNotificationRequest(
            identifier: "book-completion-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        notificationCenter.add(request)
    }

    // MARK: - Handle Notification Action
    func handleNotificationAction(_ actionIdentifier: String, for notification: UNNotification) {
        guard let action = NotificationAction(rawValue: actionIdentifier) else { return }

        switch action {
        case .startReading:
            // Post notification to open reading session
            NotificationCenter.default.post(name: .openReadingSession, object: nil)

        case .remindLater:
            // Schedule a reminder for 1 hour later
            let content = notification.request.content.mutableCopy() as! UNMutableNotificationContent
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)

            let request = UNNotificationRequest(
                identifier: "remind-later-\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request)

        case .viewProgress:
            // Post notification to open progress/goals view
            NotificationCenter.default.post(name: .openGoalsView, object: nil)

        case .dismiss:
            // No action needed
            break
        }
    }

    // MARK: - Helper Methods
    private func ordinal(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
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
