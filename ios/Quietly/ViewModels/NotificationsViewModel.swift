import Foundation
import SwiftUI
import UserNotifications

@MainActor
final class NotificationsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isNotificationsEnabled = false
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var dailyReminderEnabled = false
    @Published var reminderTime = Date()
    @Published var goalNotifications = true
    @Published var streakNotifications = true
    @Published var completionNotifications = true
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Dependencies
    private let notificationService = NotificationService.shared

    // MARK: - Computed Properties
    var canEnableReminders: Bool {
        permissionStatus == .authorized
    }

    var permissionStatusText: String {
        switch permissionStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Disabled in Settings"
        case .notDetermined:
            return "Not Set"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Temporary"
        @unknown default:
            return "Unknown"
        }
    }

    var reminderTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: reminderTime)
    }

    // MARK: - Data Loading
    func loadData() async {
        isLoading = true

        permissionStatus = await notificationService.checkPermissionStatus()
        isNotificationsEnabled = permissionStatus == .authorized

        // Load saved preferences
        dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")

        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            reminderTime = savedTime
        } else {
            // Default to 8 PM
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            reminderTime = Calendar.current.date(from: components) ?? Date()
        }

        goalNotifications = UserDefaults.standard.bool(forKey: "goalNotifications")
        streakNotifications = UserDefaults.standard.bool(forKey: "streakNotifications")
        completionNotifications = UserDefaults.standard.bool(forKey: "completionNotifications")

        // Set defaults if not set
        if !UserDefaults.standard.bool(forKey: "notificationPrefsSet") {
            goalNotifications = true
            streakNotifications = true
            completionNotifications = true
            UserDefaults.standard.set(true, forKey: "notificationPrefsSet")
        }

        isLoading = false
    }

    // MARK: - Permission
    func requestPermission() async {
        let granted = await notificationService.requestPermission()
        permissionStatus = await notificationService.checkPermissionStatus()
        isNotificationsEnabled = granted

        if granted {
            updateDailyReminder()
        }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Reminder Settings
    func toggleDailyReminder() {
        dailyReminderEnabled.toggle()
        UserDefaults.standard.set(dailyReminderEnabled, forKey: "dailyReminderEnabled")
        updateDailyReminder()
    }

    func updateReminderTime(_ time: Date) {
        reminderTime = time
        UserDefaults.standard.set(time, forKey: "reminderTime")
        if dailyReminderEnabled {
            updateDailyReminder()
        }
    }

    private func updateDailyReminder() {
        if dailyReminderEnabled && canEnableReminders {
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            notificationService.scheduleDailyReminder(at: components)
        } else {
            notificationService.cancelDailyReminder()
        }
    }

    // MARK: - Other Settings
    func toggleGoalNotifications() {
        goalNotifications.toggle()
        UserDefaults.standard.set(goalNotifications, forKey: "goalNotifications")
    }

    func toggleStreakNotifications() {
        streakNotifications.toggle()
        UserDefaults.standard.set(streakNotifications, forKey: "streakNotifications")
    }

    func toggleCompletionNotifications() {
        completionNotifications.toggle()
        UserDefaults.standard.set(completionNotifications, forKey: "completionNotifications")
    }

    // MARK: - Test
    func sendTestNotification() {
        notificationService.sendTestNotification()
    }

    // MARK: - Error Handling
    func clearError() {
        error = nil
    }
}
