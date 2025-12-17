import Foundation

struct Book: Codable, Identifiable, Hashable {
    let id: UUID
    let isbn: String?
    let title: String
    let author: String?
    let coverUrl: String?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let manualEntry: Bool?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case isbn
        case title
        case author
        case coverUrl = "cover_url"
        case publisher
        case publishedDate = "published_date"
        case description
        case pageCount = "page_count"
        case manualEntry = "manual_entry"
        case createdAt = "created_at"
    }

    // For creating new books
    init(
        id: UUID = UUID(),
        isbn: String? = nil,
        title: String,
        author: String? = nil,
        coverUrl: String? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        description: String? = nil,
        pageCount: Int? = nil,
        manualEntry: Bool? = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.coverUrl = coverUrl
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.description = description
        self.pageCount = pageCount
        self.manualEntry = manualEntry
        self.createdAt = createdAt
    }
}

// MARK: - Insert Model (for creating new books)
struct BookInsert: Codable {
    let isbn: String?
    let title: String
    let author: String?
    let coverUrl: String?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let manualEntry: Bool?

    enum CodingKeys: String, CodingKey {
        case isbn
        case title
        case author
        case coverUrl = "cover_url"
        case publisher
        case publishedDate = "published_date"
        case description
        case pageCount = "page_count"
        case manualEntry = "manual_entry"
    }

    init(from book: Book) {
        self.isbn = book.isbn
        self.title = book.title
        self.author = book.author
        self.coverUrl = book.coverUrl
        self.publisher = book.publisher
        self.publishedDate = book.publishedDate
        self.description = book.description
        self.pageCount = book.pageCount
        self.manualEntry = book.manualEntry
    }
}
