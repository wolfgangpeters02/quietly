import UIKit

// MARK: - Quick Action Types

enum QuickActionType: String {
    case startReading = "com.quietly.startReading"
    case continueReading = "com.quietly.continueReading"
    case addBook = "com.quietly.addBook"
    case viewGoals = "com.quietly.viewGoals"
}

// MARK: - Quick Actions Service

final class QuickActionsService {
    static let shared = QuickActionsService()

    private init() {}

    /// Configure dynamic quick actions based on user's reading state
    func updateQuickActions() {
        let data = WidgetDataProvider.shared.getReadingData()

        var shortcutItems: [UIApplicationShortcutItem] = []

        // Continue Reading (if there's an active book)
        if let bookTitle = data.currentBookTitle {
            let continueItem = UIApplicationShortcutItem(
                type: QuickActionType.continueReading.rawValue,
                localizedTitle: "Continue Reading",
                localizedSubtitle: bookTitle,
                icon: UIApplicationShortcutIcon(systemImageName: "play.fill"),
                userInfo: nil
            )
            shortcutItems.append(continueItem)
        }

        // Start Reading Session
        let startItem = UIApplicationShortcutItem(
            type: QuickActionType.startReading.rawValue,
            localizedTitle: "Start Reading",
            localizedSubtitle: "Begin a reading session",
            icon: UIApplicationShortcutIcon(systemImageName: "book.fill"),
            userInfo: nil
        )
        shortcutItems.append(startItem)

        // Add Book
        let addBookItem = UIApplicationShortcutItem(
            type: QuickActionType.addBook.rawValue,
            localizedTitle: "Add Book",
            localizedSubtitle: "Add a new book to your library",
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill"),
            userInfo: nil
        )
        shortcutItems.append(addBookItem)

        // View Goals (if user has goals)
        let goalsItem = UIApplicationShortcutItem(
            type: QuickActionType.viewGoals.rawValue,
            localizedTitle: "View Goals",
            localizedSubtitle: "Check your reading progress",
            icon: UIApplicationShortcutIcon(systemImageName: "target"),
            userInfo: nil
        )
        shortcutItems.append(goalsItem)

        // Limit to 4 items (iOS maximum)
        UIApplication.shared.shortcutItems = Array(shortcutItems.prefix(4))
    }

    /// Handle a quick action from the app launch
    /// Returns true if the action was handled
    @MainActor
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let actionType = QuickActionType(rawValue: shortcutItem.type) else {
            return false
        }

        HapticService.shared.buttonTap()

        switch actionType {
        case .startReading, .continueReading:
            // Post notification to open reading session
            NotificationCenter.default.post(name: .openReadingSession, object: nil)
            return true

        case .addBook:
            // Post notification to show add book sheet
            NotificationCenter.default.post(name: .showAddBook, object: nil)
            return true

        case .viewGoals:
            // Post notification to open goals view
            NotificationCenter.default.post(name: .openGoalsView, object: nil)
            return true
        }
    }
}

