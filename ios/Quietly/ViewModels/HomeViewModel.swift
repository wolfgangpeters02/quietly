import Foundation
import SwiftUI
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userBooks: [UserBook] = []
    @Published var stats = ReadingStats()
    @Published var selectedTab: ReadingStatus? = .reading
    @Published var isLoading = false
    @Published var error: String?
    @Published var showAddBook = false
    @Published var searchText = ""

    // MARK: - Dependencies
    private let bookService = BookService()
    private let sessionService = SessionService()
    private let goalService = GoalService()

    // MARK: - Goal Progress
    @Published var goalProgress: [GoalProgress] = []

    var dailyGoalProgress: GoalProgress? {
        goalProgress.first { $0.goal.goalType == .dailyMinutes }
    }

    // MARK: - Computed Properties
    var filteredBooks: [UserBook] {
        var books = bookService.filterBooks(userBooks, by: selectedTab)

        if !searchText.isEmpty {
            books = bookService.searchBooks(searchText, in: books)
        }

        return books
    }

    var readingBooks: [UserBook] {
        userBooks.filter { $0.status == .reading }
    }

    var upNextBooks: [UserBook] {
        userBooks.filter { $0.status == .wantToRead }
    }

    var completedBooks: [UserBook] {
        userBooks.filter { $0.status == .completed }
    }

    var currentlyReadingBook: UserBook? {
        readingBooks.first
    }

    // MARK: - Data Loading
    func loadData(context: ModelContext) {
        isLoading = true
        error = nil

        userBooks = bookService.fetchUserBooks(context: context)
        stats = bookService.getReadingStats(from: userBooks)
        stats.readingStreak = sessionService.calculateReadingStreak(context: context)

        // Load goal progress
        let goals = goalService.fetchGoals(context: context)
        goalProgress = goalService.calculateAllProgress(for: goals, context: context)

        // Update widget data
        updateWidgetData(context: context)

        // Index books in Spotlight
        SpotlightService.shared.indexAllBooks(userBooks)

        isLoading = false
    }

    // MARK: - Widget Integration
    private func updateWidgetData(context: ModelContext) {
        let currentBook = currentlyReadingBook
        let todayMinutes = sessionService.getTodayReadingMinutes(context: context)

        WidgetDataProvider.shared.updateAllData(
            currentBook: currentBook.map { book in
                (
                    title: book.book?.title,
                    author: book.book?.author,
                    progress: book.progress,
                    coverUrl: book.book?.coverUrl
                )
            },
            todayMinutes: todayMinutes,
            streak: stats.readingStreak,
            dailyGoalMinutes: 30, // Default, will be updated from goals
            booksCompletedThisYear: stats.booksCompletedThisYear
        )
    }

    func refresh(context: ModelContext) {
        loadData(context: context)
    }

    // MARK: - Book Actions
    func removeBook(_ userBook: UserBook, context: ModelContext) {
        bookService.removeFromLibrary(userBook: userBook, context: context)
        userBooks.removeAll { $0.id == userBook.id }
        stats = bookService.getReadingStats(from: userBooks)
    }

    func updateBookStatus(_ userBook: UserBook, to status: ReadingStatus, context: ModelContext) {
        bookService.updateStatus(userBook: userBook, status: status, context: context)
        if let index = userBooks.firstIndex(where: { $0.id == userBook.id }) {
            userBooks[index].status = status
        }
        stats = bookService.getReadingStats(from: userBooks)
    }

    // MARK: - Tab Counts
    func countForTab(_ status: ReadingStatus?) -> Int {
        switch status {
        case .reading:
            return readingBooks.count
        case .wantToRead:
            return upNextBooks.count
        case .completed:
            return completedBooks.count
        case .none:
            return userBooks.count
        }
    }

    // MARK: - Error Handling
    func clearError() {
        error = nil
    }
}
