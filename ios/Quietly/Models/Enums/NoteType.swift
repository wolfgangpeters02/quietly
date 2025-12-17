import Foundation

enum NoteType: String, Codable, CaseIterable, Identifiable {
    case note = "note"
    case quote = "quote"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .note: return "Note"
        case .quote: return "Quote"
        }
    }

    var iconName: String {
        switch self {
        case .note: return "note.text"
        case .quote: return "quote.opening"
        }
    }
}
