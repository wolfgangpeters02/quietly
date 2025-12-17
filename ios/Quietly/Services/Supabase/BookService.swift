import Foundation
import Supabase

final class BookService {
    private let client = SupabaseManager.shared.client

    // MARK: - Fetch User Books
    func fetchUserBooks() async throws -> [UserBook] {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [UserBook] = try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .select("*, books(*)")
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Fetch User Book by ID
    func fetchUserBook(id: UUID) async throws -> UserBook? {
        let response: [UserBook] = try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .select("*, books(*)")
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Fetch User Book by Book ID
    func fetchUserBook(bookId: UUID) async throws -> UserBook? {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [UserBook] = try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .select("*, books(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("book_id", value: bookId.uuidString)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Add Book to Library
    func addBook(_ book: Book, status: ReadingStatus = .wantToRead) async throws -> UserBook {
        let userId = try SupabaseManager.shared.requireUserId()

        // First, insert or get the book
        let bookInsert = BookInsert(from: book)
        let insertedBooks: [Book] = try await client.database
            .from(SupabaseTable.books.rawValue)
            .upsert(bookInsert, onConflict: "isbn")
            .select()
            .execute()
            .value

        guard let insertedBook = insertedBooks.first else {
            throw SupabaseError.databaseError("Failed to insert book")
        }

        // Then create user_book relationship
        let userBookInsert = UserBookInsert(
            userId: userId,
            bookId: insertedBook.id,
            status: status,
            currentPage: 0
        )

        let userBooks: [UserBook] = try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .insert(userBookInsert)
            .select("*, books(*)")
            .execute()
            .value

        guard let userBook = userBooks.first else {
            throw SupabaseError.databaseError("Failed to create user book")
        }

        return userBook
    }

    // MARK: - Update Book Status
    func updateStatus(userBookId: UUID, status: ReadingStatus) async throws {
        var update = UserBookUpdate()
        update.status = status

        if status == .reading {
            update.startedAt = Date()
        } else if status == .completed {
            update.completedAt = Date()
        }

        try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .update(update)
            .eq("id", value: userBookId.uuidString)
            .execute()
    }

    // MARK: - Update Current Page
    func updateCurrentPage(userBookId: UUID, page: Int) async throws {
        try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .update(["current_page": page])
            .eq("id", value: userBookId.uuidString)
            .execute()
    }

    // MARK: - Update Rating
    func updateRating(userBookId: UUID, rating: Int) async throws {
        try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .update(["rating": rating])
            .eq("id", value: userBookId.uuidString)
            .execute()
    }

    // MARK: - Remove Book from Library
    func removeFromLibrary(userBookId: UUID) async throws {
        try await client.database
            .from(SupabaseTable.userBooks.rawValue)
            .delete()
            .eq("id", value: userBookId.uuidString)
            .execute()
    }

    // MARK: - Search Books (local)
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

        return stats
    }
}
