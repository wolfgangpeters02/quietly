import Foundation
import SwiftUI

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
    func loadData() async {
        isLoading = true
        error = nil

        do {
            async let booksTask = bookService.fetchUserBooks()
            async let streakTask = sessionService.calculateReadingStreak()

            let (books, streak) = try await (booksTask, streakTask)

            userBooks = books
            stats = bookService.getReadingStats(from: books)
            stats.readingStreak = streak

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }

    // MARK: - Book Actions
    func removeBook(_ userBook: UserBook) async {
        do {
            try await bookService.removeFromLibrary(userBookId: userBook.id)
            userBooks.removeAll { $0.id == userBook.id }
            stats = bookService.getReadingStats(from: userBooks)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateBookStatus(_ userBook: UserBook, to status: ReadingStatus) async {
        do {
            try await bookService.updateStatus(userBookId: userBook.id, status: status)
            if let index = userBooks.firstIndex(where: { $0.id == userBook.id }) {
                userBooks[index].status = status
            }
            stats = bookService.getReadingStats(from: userBooks)
        } catch {
            self.error = error.localizedDescription
        }
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
