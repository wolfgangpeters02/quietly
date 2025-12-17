import Foundation

enum ReadingStatus: String, Codable, CaseIterable, Identifiable {
    case wantToRead = "want_to_read"
    case reading = "reading"
    case completed = "completed"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wantToRead: return "Up Next"
        case .reading: return "Reading"
        case .completed: return "Completed"
        }
    }

    var tabName: String {
        switch self {
        case .wantToRead: return "Next"
        case .reading: return "Reading"
        case .completed: return "Done"
        }
    }

    var iconName: String {
        switch self {
        case .wantToRead: return "bookmark"
        case .reading: return "book"
        case .completed: return "checkmark.circle"
        }
    }
}
