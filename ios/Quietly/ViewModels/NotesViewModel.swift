import Foundation
import SwiftUI

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
    func loadData() async {
        isLoading = true

        do {
            allNotes = try await noteService.fetchAllNotes()
            groupedNotes = noteService.groupNotesByBook(allNotes)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }

    // MARK: - Note Actions
    func deleteNote(_ note: Note) async {
        do {
            try await noteService.deleteNote(noteId: note.id)
            allNotes.removeAll { $0.id == note.id }
            groupedNotes = noteService.groupNotesByBook(allNotes)
        } catch {
            self.error = error.localizedDescription
        }
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
