import Foundation

// MARK: - Notification.Name Extensions

extension Notification.Name {
    /// Posted when user taps "Start Reading" from a notification
    static let openReadingSession = Notification.Name("openReadingSession")

    /// Posted when user taps "View Progress" from a notification
    static let openGoalsView = Notification.Name("openGoalsView")

    /// Posted when user taps a book-related action from a notification
    static let openLibrary = Notification.Name("openLibrary")

    /// Posted when widget data should be refreshed
    static let refreshWidgetData = Notification.Name("refreshWidgetData")

    /// Posted to trigger reading session from deep link (after navigating to Home)
    static let triggerReadingSession = Notification.Name("triggerReadingSession")

    /// Posted to show add book sheet from deep link
    static let showAddBook = Notification.Name("showAddBook")
}
