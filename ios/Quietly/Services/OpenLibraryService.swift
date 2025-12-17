import Foundation

// MARK: - OpenLibrary Response Models
struct OpenLibrarySearchResponse: Codable {
    let numFound: Int
    let docs: [OpenLibraryBook]

    enum CodingKeys: String, CodingKey {
        case numFound = "num_found"
        case docs
    }
}

struct OpenLibraryBook: Codable, Identifiable {
    let key: String
    let title: String
    let authorName: [String]?
    let coverId: Int?
    let isbn: [String]?
    let publishYear: [Int]?
    let publisher: [String]?
    let numberOfPagesMedian: Int?

    var id: String { key }

    var author: String? {
        authorName?.first
    }

    var coverUrl: String? {
        guard let id = coverId else { return nil }
        return "https://covers.openlibrary.org/b/id/\(id)-L.jpg"
    }

    var firstPublishYear: Int? {
        publishYear?.min()
    }

    var firstPublisher: String? {
        publisher?.first
    }

    var firstIsbn: String? {
        isbn?.first
    }

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case authorName = "author_name"
        case coverId = "cover_i"
        case isbn
        case publishYear = "publish_year"
        case publisher
        case numberOfPagesMedian = "number_of_pages_median"
    }

    // Convert to our Book model
    func toBook() -> Book {
        Book(
            isbn: firstIsbn,
            title: title,
            author: author,
            coverUrl: coverUrl,
            publisher: firstPublisher,
            publishedDate: firstPublishYear.map { String($0) },
            description: nil,
            pageCount: numberOfPagesMedian,
            manualEntry: false
        )
    }
}

struct OpenLibraryISBNResponse: Codable {
    let title: String
    let authors: [OpenLibraryAuthorRef]?
    let covers: [Int]?
    let numberOfPages: Int?
    let publishers: [String]?
    let publishDate: String?
    let description: OpenLibraryDescription?

    var coverUrl: String? {
        guard let id = covers?.first else { return nil }
        return "https://covers.openlibrary.org/b/id/\(id)-L.jpg"
    }

    enum CodingKeys: String, CodingKey {
        case title
        case authors
        case covers
        case numberOfPages = "number_of_pages"
        case publishers
        case publishDate = "publish_date"
        case description
    }
}

struct OpenLibraryAuthorRef: Codable {
    let key: String
}

struct OpenLibraryDescription: Codable {
    let value: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let objectValue = try? container.decode([String: String].self) {
            value = objectValue["value"]
        } else {
            value = nil
        }
    }
}

struct OpenLibraryAuthor: Codable {
    let name: String
}

// MARK: - OpenLibrary Service
final class OpenLibraryService {
    private let baseUrl = AppConstants.OpenLibrary.baseUrl

    // MARK: - Search Books
    func searchBooks(query: String, limit: Int = 5) async throws -> [OpenLibraryBook] {
        guard let encodedQuery = query.urlEncoded else {
            return []
        }

        let urlString = "\(AppConstants.OpenLibrary.searchUrl)?q=\(encodedQuery)&limit=\(limit)"
        guard let url = URL(string: urlString) else {
            return []
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)

        return response.docs
    }

    // MARK: - Lookup by ISBN
    func lookupISBN(_ isbn: String) async throws -> Book? {
        let cleanedISBN = isbn.cleanedISBN
        let urlString = "\(AppConstants.OpenLibrary.isbnUrl)/\(cleanedISBN).json"

        guard let url = URL(string: urlString) else {
            return nil
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        let isbnResponse = try JSONDecoder().decode(OpenLibraryISBNResponse.self, from: data)

        // Fetch author name if available
        var authorName: String?
        if let authorRef = isbnResponse.authors?.first {
            authorName = try await fetchAuthorName(key: authorRef.key)
        }

        return Book(
            isbn: cleanedISBN,
            title: isbnResponse.title,
            author: authorName,
            coverUrl: isbnResponse.coverUrl,
            publisher: isbnResponse.publishers?.first,
            publishedDate: isbnResponse.publishDate,
            description: isbnResponse.description?.value,
            pageCount: isbnResponse.numberOfPages,
            manualEntry: false
        )
    }

    // MARK: - Fetch Author Name
    private func fetchAuthorName(key: String) async throws -> String? {
        let urlString = "\(baseUrl)\(key).json"

        guard let url = URL(string: urlString) else {
            return nil
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        let author = try JSONDecoder().decode(OpenLibraryAuthor.self, from: data)
        return author.name
    }
}
