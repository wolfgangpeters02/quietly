package com.quietly.app.ui.screens.notes

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.quietly.app.data.model.Note
import com.quietly.app.data.model.NoteType
import com.quietly.app.data.model.UserBook
import com.quietly.app.data.repository.BookRepository
import com.quietly.app.data.repository.NoteRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

data class NotesUiState(
    val isLoading: Boolean = true,
    val notes: List<Note> = emptyList(),
    val filteredNotes: List<Note> = emptyList(),
    val searchQuery: String = "",
    val selectedFilter: NoteFilter = NoteFilter.ALL,
    val showAddDialog: Boolean = false,
    val userBooks: List<UserBook> = emptyList(),
    val selectedBookId: String? = null,
    val noteContent: String = "",
    val noteType: NoteType = NoteType.NOTE,
    val pageNumber: String = "",
    val error: String? = null
)

enum class NoteFilter {
    ALL, NOTES, QUOTES
}

@HiltViewModel
class NotesViewModel @Inject constructor(
    private val noteRepository: NoteRepository,
    private val bookRepository: BookRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(NotesUiState())
    val uiState: StateFlow<NotesUiState> = _uiState.asStateFlow()

    init {
        loadNotes()
    }

    fun loadNotes() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val notes = noteRepository.getAllNotes().first()
                val userBooks = bookRepository.getUserBooks().first()
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    notes = notes,
                    filteredNotes = notes,
                    userBooks = userBooks
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load notes"
                )
            }
        }
    }

    fun updateSearchQuery(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
        filterNotes()
    }

    fun updateFilter(filter: NoteFilter) {
        _uiState.value = _uiState.value.copy(selectedFilter = filter)
        filterNotes()
    }

    private fun filterNotes() {
        val state = _uiState.value
        var filtered = state.notes

        // Filter by type
        filtered = when (state.selectedFilter) {
            NoteFilter.ALL -> filtered
            NoteFilter.NOTES -> filtered.filter { it.noteType == NoteType.NOTE }
            NoteFilter.QUOTES -> filtered.filter { it.noteType == NoteType.QUOTE }
        }

        // Filter by search query
        if (state.searchQuery.isNotBlank()) {
            filtered = filtered.filter {
                it.content.contains(state.searchQuery, ignoreCase = true) ||
                        it.userBook?.book?.title?.contains(state.searchQuery, ignoreCase = true) == true
            }
        }

        _uiState.value = _uiState.value.copy(filteredNotes = filtered)
    }

    fun showAddDialog(bookId: String? = null) {
        _uiState.value = _uiState.value.copy(
            showAddDialog = true,
            selectedBookId = bookId,
            noteContent = "",
            noteType = NoteType.NOTE,
            pageNumber = ""
        )
    }

    fun hideAddDialog() {
        _uiState.value = _uiState.value.copy(showAddDialog = false)
    }

    fun updateSelectedBook(bookId: String) {
        _uiState.value = _uiState.value.copy(selectedBookId = bookId)
    }

    fun updateNoteContent(content: String) {
        _uiState.value = _uiState.value.copy(noteContent = content)
    }

    fun updateNoteType(type: NoteType) {
        _uiState.value = _uiState.value.copy(noteType = type)
    }

    fun updatePageNumber(page: String) {
        _uiState.value = _uiState.value.copy(pageNumber = page)
    }

    fun createNote() {
        val state = _uiState.value
        if (state.selectedBookId == null) {
            _uiState.value = state.copy(error = "Please select a book")
            return
        }
        if (state.noteContent.isBlank()) {
            _uiState.value = state.copy(error = "Please enter note content")
            return
        }

        viewModelScope.launch {
            val result = noteRepository.createNote(
                userBookId = state.selectedBookId,
                content = state.noteContent,
                noteType = state.noteType,
                pageNumber = state.pageNumber.toIntOrNull()
            )
            result.fold(
                onSuccess = {
                    _uiState.value = _uiState.value.copy(showAddDialog = false)
                    loadNotes()
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to create note"
                    )
                }
            )
        }
    }

    fun deleteNote(noteId: String) {
        viewModelScope.launch {
            val result = noteRepository.deleteNote(noteId)
            result.fold(
                onSuccess = { loadNotes() },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to delete note"
                    )
                }
            )
        }
    }

    fun getNotesGroupedByBook(): Map<String?, List<Note>> {
        return _uiState.value.filteredNotes.groupBy { it.userBook?.book?.title }
    }
}
