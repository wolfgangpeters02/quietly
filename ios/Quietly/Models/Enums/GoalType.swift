import Foundation

enum GoalType: String, Codable, CaseIterable, Identifiable {
    case dailyMinutes = "daily_minutes"
    case weeklyMinutes = "weekly_minutes"
    case booksPerMonth = "books_per_month"
    case booksPerYear = "books_per_year"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dailyMinutes: return "Daily Reading"
        case .weeklyMinutes: return "Weekly Reading"
        case .booksPerMonth: return "Books per Month"
        case .booksPerYear: return "Books per Year"
        }
    }

    var unit: String {
        switch self {
        case .dailyMinutes, .weeklyMinutes: return "minutes"
        case .booksPerMonth, .booksPerYear: return "books"
        }
    }

    var iconName: String {
        switch self {
        case .dailyMinutes: return "sun.max"
        case .weeklyMinutes: return "calendar.badge.clock"
        case .booksPerMonth: return "calendar"
        case .booksPerYear: return "star"
        }
    }

    var periodDescription: String {
        switch self {
        case .dailyMinutes: return "per day"
        case .weeklyMinutes: return "per week"
        case .booksPerMonth: return "per month"
        case .booksPerYear: return "per year"
        }
    }
}
