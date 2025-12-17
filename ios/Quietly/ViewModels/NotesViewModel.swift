import Foundation
import SwiftUI
import SwiftData

@MainActor
final class NotesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var allNotes: [Note] = []
    @Published var groupedNotes: [BookNotesGroup] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Dependencies
    private let noteService = NoteService()

    // MARK: - Computed Properties
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return allNotes
        }
        return noteService.searchNotes(searchText, in: allNotes)
    }

    var filteredGroupedNotes: [BookNotesGroup] {
        if searchText.isEmpty {
            return groupedNotes
        }
        let filtered = noteService.searchNotes(searchText, in: allNotes)
        return noteService.groupNotesByBook(filtered)
    }

    var hasNotes: Bool {
        !allNotes.isEmpty
    }

    var totalNoteCount: Int {
        allNotes.count
    }

    // MARK: - Data Loading
    func loadData(context: ModelContext) {
        isLoading = true

        allNotes = noteService.fetchAllNotes(context: context)
        groupedNotes = noteService.groupNotesByBook(allNotes)

        isLoading = false
    }

    func refresh(context: ModelContext) {
        loadData(context: context)
    }

    // MARK: - Note Actions
    func deleteNote(_ note: Note, context: ModelContext) {
        noteService.deleteNote(note, context: context)
        allNotes.removeAll { $0.id == note.id }
        groupedNotes = noteService.groupNotesByBook(allNotes)
        HapticService.shared.deleted()
    }

    // MARK: - Search
    func filterNotes(_ query: String) {
        searchText = query
    }

    func clearSearch() {
        searchText = ""
    }

    // MARK: - Error Handling
    func clearError() {
        error = nil
    }
}
