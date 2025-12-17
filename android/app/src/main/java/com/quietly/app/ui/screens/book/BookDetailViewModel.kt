package com.quietly.app.ui.screens.book

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.quietly.app.data.model.Note
import com.quietly.app.data.model.ReadingSession
import com.quietly.app.data.model.ReadingStatus
import com.quietly.app.data.model.UserBook
import com.quietly.app.data.repository.BookRepository
import com.quietly.app.data.repository.NoteRepository
import com.quietly.app.data.repository.SessionRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

data class BookDetailUiState(
    val isLoading: Boolean = true,
    val userBook: UserBook? = null,
    val sessions: List<ReadingSession> = emptyList(),
    val notes: List<Note> = emptyList(),
    val totalReadingMinutes: Int = 0,
    val error: String? = null
)

@HiltViewModel
class BookDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val bookRepository: BookRepository,
    private val sessionRepository: SessionRepository,
    private val noteRepository: NoteRepository
) : ViewModel() {

    private val userBookId: String = checkNotNull(savedStateHandle["userBookId"])

    private val _uiState = MutableStateFlow(BookDetailUiState())
    val uiState: StateFlow<BookDetailUiState> = _uiState.asStateFlow()

    init {
        loadBookDetails()
    }

    fun loadBookDetails() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val userBook = bookRepository.getUserBook(userBookId)
                val sessions = sessionRepository.getSessionsForBook(userBookId).first()
                val notes = noteRepository.getNotesForBook(userBookId).first()
                val totalMinutes = sessions.sumOf { it.durationSeconds ?: 0 } / 60

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    userBook = userBook,
                    sessions = sessions,
                    notes = notes,
                    totalReadingMinutes = totalMinutes
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load book details"
                )
            }
        }
    }

    fun updateStatus(status: ReadingStatus) {
        val currentUserBook = _uiState.value.userBook ?: return

        viewModelScope.launch {
            val updatedUserBook = currentUserBook.copy(
                status = status,
                startedAt = if (status == ReadingStatus.READING && currentUserBook.startedAt == null) {
                    java.time.Instant.now().toString()
                } else currentUserBook.startedAt,
                finishedAt = if (status == ReadingStatus.COMPLETED) {
                    java.time.Instant.now().toString()
                } else null
            )

            val result = bookRepository.updateUserBook(updatedUserBook)
            result.fold(
                onSuccess = { updated ->
                    _uiState.value = _uiState.value.copy(userBook = updated)
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to update status"
                    )
                }
            )
        }
    }

    fun updateCurrentPage(page: Int) {
        val currentUserBook = _uiState.value.userBook ?: return

        viewModelScope.launch {
            val updatedUserBook = currentUserBook.copy(currentPage = page)
            val result = bookRepository.updateUserBook(updatedUserBook)
            result.fold(
                onSuccess = { updated ->
                    _uiState.value = _uiState.value.copy(userBook = updated)
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to update page"
                    )
                }
            )
        }
    }

    fun updateRating(rating: Int) {
        val currentUserBook = _uiState.value.userBook ?: return

        viewModelScope.launch {
            val updatedUserBook = currentUserBook.copy(rating = rating)
            val result = bookRepository.updateUserBook(updatedUserBook)
            result.fold(
                onSuccess = { updated ->
                    _uiState.value = _uiState.value.copy(userBook = updated)
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to update rating"
                    )
                }
            )
        }
    }

    fun deleteBook() {
        viewModelScope.launch {
            val result = bookRepository.deleteUserBook(userBookId)
            result.fold(
                onSuccess = { /* Navigation handled by UI */ },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to delete book"
                    )
                }
            )
        }
    }

    fun deleteNote(noteId: String) {
        viewModelScope.launch {
            val result = noteRepository.deleteNote(noteId)
            result.fold(
                onSuccess = {
                    _uiState.value = _uiState.value.copy(
                        notes = _uiState.value.notes.filter { it.id != noteId }
                    )
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to delete note"
                    )
                }
            )
        }
    }
}
