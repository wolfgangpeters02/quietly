import Foundation

enum NoteType: String, Codable, CaseIterable, Identifiable {
    case note = "note"

    var id: String { rawValue }

    var displayName: String {
        return "Note"
    }

    var iconName: String {
        return "note.text"
    }
}
