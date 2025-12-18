import Foundation
import SwiftData

final class BookService {
    // MARK: - Fetch User Books
    func fetchUserBooks(context: ModelContext) -> [UserBook] {
        let descriptor = FetchDescriptor<UserBook>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch user books: \(error)")
            return []
        }
    }

    // MARK: - Fetch User Book by ID
    func fetchUserBook(id: UUID, context: ModelContext) -> UserBook? {
        let descriptor = FetchDescriptor<UserBook>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Failed to fetch user book: \(error)")
            return nil
        }
    }

    // MARK: - Fetch User Book by Book
    func fetchUserBook(book: Book, context: ModelContext) -> UserBook? {
        let bookId = book.id
        let descriptor = FetchDescriptor<UserBook>(
            predicate: #Predicate { userBook in
                userBook.book?.id == bookId
            }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Failed to fetch user book: \(error)")
            return nil
        }
    }

    // MARK: - Add Book to Library
    func addBook(
        title: String,
        author: String? = nil,
        isbn: String? = nil,
        coverUrl: String? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        bookDescription: String? = nil,
        pageCount: Int? = nil,
        manualEntry: Bool = false,
        status: ReadingStatus = .wantToRead,
        context: ModelContext
    ) -> UserBook {
        // Check if book with same ISBN exists
        var existingBook: Book?
        if let isbn = isbn, !isbn.isEmpty {
            let descriptor = FetchDescriptor<Book>(
                predicate: #Predicate { $0.isbn == isbn }
            )
            existingBook = try? context.fetch(descriptor).first
        }

        let book: Book
        if let existing = existingBook {
            book = existing
        } else {
            book = Book(
                isbn: isbn,
                title: title,
                author: author,
                coverUrl: coverUrl,
                publisher: publisher,
                publishedDate: publishedDate,
                bookDescription: bookDescription,
                pageCount: pageCount,
                manualEntry: manualEntry
            )
            context.insert(book)
        }

        // If this is the first book, set status to reading
        let finalStatus: ReadingStatus
        let existingBooksDescriptor = FetchDescriptor<UserBook>()
        let existingBooksCount = (try? context.fetchCount(existingBooksDescriptor)) ?? 0
        if existingBooksCount == 0 {
            finalStatus = .reading
        } else {
            finalStatus = status
        }

        let userBook = UserBook(
            book: book,
            status: finalStatus,
            currentPage: 0,
            startedAt: finalStatus == .reading ? Date() : nil
        )
        context.insert(userBook)

        // Index in Spotlight
        SpotlightService.shared.indexBook(book, userBook: userBook)

        return userBook
    }

    // MARK: - Update Book Status
    func updateStatus(userBook: UserBook, status: ReadingStatus, context: ModelContext) {
        userBook.status = status
        userBook.updatedAt = Date()

        if status == .reading && userBook.startedAt == nil {
            userBook.startedAt = Date()
        } else if status == .completed {
            userBook.completedAt = Date()
        }
    }

    // MARK: - Update Current Page
    func updateCurrentPage(userBook: UserBook, page: Int, context: ModelContext) {
        userBook.currentPage = page
        userBook.updatedAt = Date()
    }

    // MARK: - Update Rating
    func updateRating(userBook: UserBook, rating: Int, context: ModelContext) {
        userBook.rating = rating
        userBook.updatedAt = Date()
    }

    // MARK: - Remove Book from Library
    func removeFromLibrary(userBook: UserBook, context: ModelContext) {
        // Remove from Spotlight
        if let book = userBook.book {
            SpotlightService.shared.removeBook(book.id)
        }
        context.delete(userBook)
    }

    // MARK: - Search Books (local filter)
    func searchBooks(_ query: String, in books: [UserBook]) -> [UserBook] {
        let lowercasedQuery = query.lowercased()
        return books.filter { userBook in
            guard let book = userBook.book else { return false }
            return book.title.lowercased().contains(lowercasedQuery) ||
                   (book.author?.lowercased().contains(lowercasedQuery) ?? false)
        }
    }

    // MARK: - Filter Books by Status
    func filterBooks(_ books: [UserBook], by status: ReadingStatus?) -> [UserBook] {
        guard let status = status else { return books }
        return books.filter { $0.status == status }
    }

    // MARK: - Get Reading Stats
    func getReadingStats(from books: [UserBook]) -> ReadingStats {
        var stats = ReadingStats()

        stats.totalBooks = books.count
        stats.booksCompleted = books.filter { $0.status == .completed }.count
        stats.booksReading = books.filter { $0.status == .reading }.count
        stats.booksWantToRead = books.filter { $0.status == .wantToRead }.count

        // Calculate books completed this year
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        stats.booksCompletedThisYear = books.filter { book in
            guard book.status == .completed,
                  let completedAt = book.completedAt else { return false }
            return calendar.component(.year, from: completedAt) == currentYear
        }.count

        return stats
    }
}
