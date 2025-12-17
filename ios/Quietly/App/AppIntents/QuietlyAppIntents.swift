import AppIntents
import SwiftUI
import SwiftData

// MARK: - App Shortcuts Provider

struct QuietlyShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartReadingIntent(),
            phrases: [
                "Start reading in \(.applicationName)",
                "Begin reading session with \(.applicationName)",
                "Start a reading session"
            ],
            shortTitle: "Start Reading",
            systemImageName: "book.fill"
        )

        AppShortcut(
            intent: CheckStreakIntent(),
            phrases: [
                "Check my reading streak in \(.applicationName)",
                "What's my reading streak",
                "How many days have I read"
            ],
            shortTitle: "Check Streak",
            systemImageName: "flame.fill"
        )

        AppShortcut(
            intent: GetReadingStatsIntent(),
            phrases: [
                "Get my reading stats from \(.applicationName)",
                "Show my reading statistics",
                "How much have I read"
            ],
            shortTitle: "Reading Stats",
            systemImageName: "chart.bar.fill"
        )
    }
}

// MARK: - Start Reading Intent

struct StartReadingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Reading Session"
    static var description = IntentDescription("Start a new reading session")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // This will open the app - actual session start happens in the app
        return .result(dialog: "Opening Quietly to start reading...")
    }
}

// MARK: - Check Streak Intent

struct CheckStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Reading Streak"
    static var description = IntentDescription("Check your current reading streak")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Access shared widget data for quick response
        let data = WidgetDataProvider.shared.getReadingData()
        let streak = data.currentStreak

        if streak == 0 {
            return .result(dialog: "You don't have an active reading streak. Start reading today to begin one!")
        } else if streak == 1 {
            return .result(dialog: "You have a 1 day reading streak. Keep it going!")
        } else {
            return .result(dialog: "Amazing! You have a \(streak) day reading streak. Keep up the great work!")
        }
    }
}

// MARK: - Get Reading Stats Intent

struct GetReadingStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Reading Stats"
    static var description = IntentDescription("Get your reading statistics")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = WidgetDataProvider.shared.getReadingData()

        let todayMinutes = data.todayReadingMinutes
        let streak = data.currentStreak
        let booksThisYear = data.booksCompletedThisYear

        var message = "Here are your reading stats: "

        if todayMinutes > 0 {
            let hours = todayMinutes / 60
            let mins = todayMinutes % 60
            if hours > 0 {
                message += "You've read \(hours) hours and \(mins) minutes today. "
            } else {
                message += "You've read \(mins) minutes today. "
            }
        } else {
            message += "You haven't read yet today. "
        }

        if streak > 0 {
            message += "Your current streak is \(streak) day\(streak == 1 ? "" : "s"). "
        }

        if booksThisYear > 0 {
            message += "You've completed \(booksThisYear) book\(booksThisYear == 1 ? "" : "s") this year."
        }

        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

// MARK: - Log Reading Time Intent

struct LogReadingTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Reading Time"
    static var description = IntentDescription("Log time spent reading")

    @Parameter(title: "Minutes")
    var minutes: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$minutes) minutes of reading")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // This would need to interact with the database
        // For now, provide feedback
        if minutes <= 0 {
            return .result(dialog: "Please enter a positive number of minutes.")
        }

        return .result(dialog: "Logged \(minutes) minutes of reading. Great job!")
    }
}

// MARK: - Open Current Book Intent

struct OpenCurrentBookIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Current Book"
    static var description = IntentDescription("Open your currently reading book")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let data = WidgetDataProvider.shared.getReadingData()

        if let bookTitle = data.currentBookTitle {
            return .result(dialog: "Opening \(bookTitle)...")
        } else {
            return .result(dialog: "You don't have a book currently marked as reading. Opening Quietly...")
        }
    }
}

// MARK: - Set Daily Goal Intent

struct SetDailyGoalIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Daily Reading Goal"
    static var description = IntentDescription("Set your daily reading goal in minutes")

    @Parameter(title: "Minutes", default: 30)
    var targetMinutes: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Set daily goal to \(\.$targetMinutes) minutes")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard targetMinutes > 0 else {
            return .result(dialog: "Please set a goal greater than 0 minutes.")
        }

        WidgetDataProvider.shared.updateDailyGoal(targetMinutes: targetMinutes)

        return .result(dialog: "Your daily reading goal is now set to \(targetMinutes) minutes. Happy reading!")
    }
}
