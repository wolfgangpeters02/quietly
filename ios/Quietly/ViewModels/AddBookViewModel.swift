import Foundation
import SwiftUI
import SwiftData

enum AddBookMethod: String, CaseIterable, Identifiable {
    case search
    case isbn
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .search: return "Search"
        case .isbn: return "ISBN"
        case .manual: return "Manual"
        }
    }

    var icon: String {
        switch self {
        case .search: return "magnifyingglass"
        case .isbn: return "barcode"
        case .manual: return "pencil"
        }
    }
}

@MainActor
final class AddBookViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedMethod: AddBookMethod = .search
    @Published var isLoading = false
    @Published var error: String?

    // Search
    @Published var searchQuery = ""
    @Published var searchResults: [OpenLibraryBook] = []
    @Published var hasSearched = false

    // ISBN
    @Published var isbnInput = ""
    @Published var isbnBook: Book?
    @Published var isbnError: String?

    // Manual
    @Published var manualTitle = ""
    @Published var manualAuthor = ""
    @Published var manualPageCount = ""
    @Published var manualCoverUrl = ""

    // MARK: - Dependencies
    private let openLibraryService = OpenLibraryService()
    private let bookService = BookService()

    // MARK: - Computed Properties
    var canSearch: Bool {
        !searchQuery.trimmed.isEmpty && !isLoading
    }

    var canAddISBN: Bool {
        isbnBook != nil && !isLoading
    }

    var canAddManual: Bool {
        !manualTitle.trimmed.isEmpty && !isLoading
    }

    var isISBNValid: Bool {
        isbnInput.isValidISBN
    }

    // MARK: - Search Methods
    func searchBooks() async {
        guard canSearch else { return }

        isLoading = true
        hasSearched = true

        do {
            searchResults = try await openLibraryService.searchBooks(query: searchQuery.trimmed)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func selectSearchResult(_ result: OpenLibraryBook, context: ModelContext) -> UserBook {
        isLoading = true

        let userBook = bookService.addBook(
            title: result.title,
            author: result.authorName?.first,
            isbn: result.isbn?.first,
            coverUrl: result.coverUrl,
            publisher: result.publisher?.first,
            publishedDate: result.firstPublishYear.map { String($0) },
            pageCount: result.numberOfPages,
            status: .wantToRead,
            context: context
        )

        isLoading = false
        HapticService.shared.bookAdded()
        return userBook
    }

    // MARK: - ISBN Methods
    func lookupISBN() async {
        guard isbnInput.isValidISBN else {
            isbnError = "Please enter a valid ISBN"
            return
        }

        isLoading = true
        isbnError = nil
        isbnBook = nil

        do {
            if let book = try await openLibraryService.lookupISBN(isbnInput.cleanedISBN) {
                isbnBook = book
            } else {
                isbnError = "No book found with this ISBN"
            }
        } catch {
            isbnError = error.localizedDescription
        }

        isLoading = false
    }

    func addISBNBook(context: ModelContext) -> UserBook? {
        guard let book = isbnBook else { return nil }

        isLoading = true

        let userBook = bookService.addBook(
            title: book.title,
            author: book.author,
            isbn: book.isbn,
            coverUrl: book.coverUrl,
            publisher: book.publisher,
            publishedDate: book.publishedDate,
            bookDescription: book.bookDescription,
            pageCount: book.pageCount,
            status: .wantToRead,
            context: context
        )

        isLoading = false
        HapticService.shared.bookAdded()
        return userBook
    }

    // MARK: - Manual Entry
    func addManualBook(context: ModelContext) -> UserBook? {
        guard !manualTitle.trimmed.isEmpty else {
            error = "Title is required"
            return nil
        }

        isLoading = true

        let userBook = bookService.addBook(
            title: manualTitle.trimmed,
            author: manualAuthor.nilIfEmpty,
            pageCount: Int(manualPageCount),
            manualEntry: true,
            status: .wantToRead,
            context: context
        )

        isLoading = false
        HapticService.shared.bookAdded()
        return userBook
    }

    // MARK: - Clear Methods
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        hasSearched = false
    }

    func clearISBN() {
        isbnInput = ""
        isbnBook = nil
        isbnError = nil
    }

    func clearManual() {
        manualTitle = ""
        manualAuthor = ""
        manualPageCount = ""
        manualCoverUrl = ""
    }

    func clearAll() {
        clearSearch()
        clearISBN()
        clearManual()
        error = nil
    }

    func clearError() {
        error = nil
    }
}
