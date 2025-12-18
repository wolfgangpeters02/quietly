import Foundation
import CoreSpotlight
import MobileCoreServices
import UniformTypeIdentifiers

/// Service for indexing books in Spotlight search
final class SpotlightService {
    static let shared = SpotlightService()

    private let searchableIndex = CSSearchableIndex.default()
    private let domainIdentifier = "com.quietly.books"

    private init() {}

    // MARK: - Index a Single Book

    /// Index a book for Spotlight search
    func indexBook(_ book: Book, userBook: UserBook) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)

        // Basic info
        attributeSet.title = book.title
        attributeSet.contentDescription = buildDescription(for: book, userBook: userBook)
        attributeSet.displayName = book.title

        // Author
        if let author = book.author {
            attributeSet.creator = author
            attributeSet.authorNames = [author]
        }

        // Keywords for better search
        var keywords = [book.title]
        if let author = book.author {
            keywords.append(author)
        }
        if let isbn = book.isbn {
            keywords.append(isbn)
        }
        keywords.append(userBook.status.displayName)
        attributeSet.keywords = keywords

        // Reading status
        attributeSet.information = userBook.status.displayName

        // Thumbnail (placeholder - in production, download and cache cover)
        if let coverUrl = book.coverUrl {
            attributeSet.thumbnailURL = URL(string: coverUrl)
        }

        // Create searchable item
        let item = CSSearchableItem(
            uniqueIdentifier: book.id.uuidString,
            domainIdentifier: domainIdentifier,
            attributeSet: attributeSet
        )

        // Item expires in 30 days (will be re-indexed on app launch)
        item.expirationDate = Date().addingTimeInterval(30 * 24 * 60 * 60)

        // Index the item
        searchableIndex.indexSearchableItems([item]) { error in
            if let error = error {
                print("Spotlight indexing error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Index All Books

    /// Index all books in the library
    func indexAllBooks(_ userBooks: [UserBook]) {
        var items: [CSSearchableItem] = []

        for userBook in userBooks {
            guard let book = userBook.book else { continue }

            let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
            attributeSet.title = book.title
            attributeSet.contentDescription = buildDescription(for: book, userBook: userBook)
            attributeSet.displayName = book.title

            if let author = book.author {
                attributeSet.creator = author
                attributeSet.authorNames = [author]
            }

            var keywords = [book.title]
            if let author = book.author {
                keywords.append(author)
            }
            keywords.append(userBook.status.displayName)
            attributeSet.keywords = keywords

            if let coverUrl = book.coverUrl {
                attributeSet.thumbnailURL = URL(string: coverUrl)
            }

            let item = CSSearchableItem(
                uniqueIdentifier: book.id.uuidString,
                domainIdentifier: domainIdentifier,
                attributeSet: attributeSet
            )
            item.expirationDate = Date().addingTimeInterval(30 * 24 * 60 * 60)

            items.append(item)
        }

        // Batch index
        searchableIndex.indexSearchableItems(items) { error in
            if let error = error {
                print("Spotlight batch indexing error: \(error.localizedDescription)")
            } else {
                print("Indexed \(items.count) books in Spotlight")
            }
        }
    }

    // MARK: - Remove from Index

    /// Remove a book from Spotlight index
    func removeBook(_ bookId: UUID) {
        searchableIndex.deleteSearchableItems(withIdentifiers: [bookId.uuidString]) { error in
            if let error = error {
                print("Spotlight removal error: \(error.localizedDescription)")
            }
        }
    }

    /// Remove all books from Spotlight index
    func removeAllBooks() {
        searchableIndex.deleteSearchableItems(withDomainIdentifiers: [domainIdentifier]) { error in
            if let error = error {
                print("Spotlight clear error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Handle Spotlight Selection

    /// Parse a Spotlight activity to get the book ID
    static func bookId(from userActivity: NSUserActivity) -> UUID? {
        guard userActivity.activityType == CSSearchableItemActionType,
              let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
              let uuid = UUID(uuidString: identifier) else {
            return nil
        }
        return uuid
    }

    // MARK: - Helpers

    private func buildDescription(for book: Book, userBook: UserBook) -> String {
        var parts: [String] = []

        if let author = book.author {
            parts.append("by \(author)")
        }

        parts.append("Status: \(userBook.status.displayName)")

        if let pageCount = book.pageCount {
            parts.append("\(pageCount) pages")
        }

        if userBook.status == .reading {
            let progress = Int(userBook.progress * 100)
            parts.append("\(progress)% complete")
        }

        return parts.joined(separator: " • ")
    }
}
