package com.quietly.app.ui.screens.session

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.quietly.app.data.model.ReadingSession
import com.quietly.app.data.model.UserBook
import com.quietly.app.data.repository.BookRepository
import com.quietly.app.data.repository.SessionRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.Instant
import javax.inject.Inject

data class ReadingSessionUiState(
    val isLoading: Boolean = true,
    val userBook: UserBook? = null,
    val session: ReadingSession? = null,
    val isPaused: Boolean = false,
    val showEndDialog: Boolean = false,
    val endPage: String = "",
    val sessionNotes: String = "",
    val error: String? = null,
    val isSessionEnded: Boolean = false
)

@HiltViewModel
class ReadingSessionViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val sessionRepository: SessionRepository,
    private val bookRepository: BookRepository
) : ViewModel() {

    private val userBookId: String = checkNotNull(savedStateHandle["userBookId"])

    private val _uiState = MutableStateFlow(ReadingSessionUiState())
    val uiState: StateFlow<ReadingSessionUiState> = _uiState.asStateFlow()

    init {
        loadAndStartSession()
    }

    private fun loadAndStartSession() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val userBook = bookRepository.getUserBook(userBookId)

                // Check for existing active session
                var session = sessionRepository.getActiveSession()

                // If no active session, start a new one
                if (session == null || session.userBookId != userBookId) {
                    val result = sessionRepository.startSession(
                        userBookId = userBookId,
                        startPage = userBook?.currentPage
                    )
                    session = result.getOrNull()
                }

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    userBook = userBook,
                    session = session,
                    endPage = userBook?.currentPage?.toString() ?: ""
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to start session"
                )
            }
        }
    }

    fun togglePause() {
        val session = _uiState.value.session ?: return

        viewModelScope.launch {
            if (_uiState.value.isPaused) {
                val result = sessionRepository.resumeSession(session.id)
                result.fold(
                    onSuccess = { updatedSession ->
                        _uiState.value = _uiState.value.copy(
                            session = updatedSession,
                            isPaused = false
                        )
                    },
                    onFailure = { e ->
                        _uiState.value = _uiState.value.copy(
                            error = e.message ?: "Failed to resume session"
                        )
                    }
                )
            } else {
                val result = sessionRepository.pauseSession(session.id)
                result.fold(
                    onSuccess = { updatedSession ->
                        _uiState.value = _uiState.value.copy(
                            session = updatedSession,
                            isPaused = true
                        )
                    },
                    onFailure = { e ->
                        _uiState.value = _uiState.value.copy(
                            error = e.message ?: "Failed to pause session"
                        )
                    }
                )
            }
        }
    }

    fun showEndDialog() {
        _uiState.value = _uiState.value.copy(showEndDialog = true)
    }

    fun hideEndDialog() {
        _uiState.value = _uiState.value.copy(showEndDialog = false)
    }

    fun updateEndPage(page: String) {
        _uiState.value = _uiState.value.copy(endPage = page)
    }

    fun updateSessionNotes(notes: String) {
        _uiState.value = _uiState.value.copy(sessionNotes = notes)
    }

    fun endSession() {
        val session = _uiState.value.session ?: return
        val endPage = _uiState.value.endPage.toIntOrNull()
        val notes = _uiState.value.sessionNotes.takeIf { it.isNotBlank() }

        viewModelScope.launch {
            val result = sessionRepository.endSession(
                sessionId = session.id,
                endPage = endPage,
                notes = notes
            )

            result.fold(
                onSuccess = { _ ->
                    // Update book's current page if provided
                    if (endPage != null) {
                        val userBook = _uiState.value.userBook
                        if (userBook != null) {
                            val updatedUserBook = userBook.copy(currentPage = endPage)
                            bookRepository.updateUserBook(updatedUserBook)
                        }
                    }
                    _uiState.value = _uiState.value.copy(
                        isSessionEnded = true,
                        showEndDialog = false
                    )
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to end session"
                    )
                }
            )
        }
    }

    fun getStartTimeMillis(): Long {
        val session = _uiState.value.session ?: return System.currentTimeMillis()
        return try {
            Instant.parse(session.startedAt).toEpochMilli()
        } catch (e: Exception) {
            System.currentTimeMillis()
        }
    }

    fun getPausedAtMillis(): Long? {
        val session = _uiState.value.session ?: return null
        return session.pausedAt?.let {
            try {
                Instant.parse(it).toEpochMilli()
            } catch (e: Exception) {
                null
            }
        }
    }
}
