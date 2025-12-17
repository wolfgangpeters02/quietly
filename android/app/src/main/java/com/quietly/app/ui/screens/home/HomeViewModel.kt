package com.quietly.app.ui.screens.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.quietly.app.data.model.ReadingStatus
import com.quietly.app.data.model.UserBook
import com.quietly.app.data.repository.BookRepository
import com.quietly.app.data.repository.GoalRepository
import com.quietly.app.data.repository.SessionRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeStats(
    val booksRead: Int = 0,
    val minutesToday: Int = 0,
    val currentStreak: Int = 0,
    val totalBooks: Int = 0
)

data class HomeUiState(
    val isLoading: Boolean = true,
    val stats: HomeStats = HomeStats(),
    val allBooks: List<UserBook> = emptyList(),
    val selectedTab: Int = 0,
    val error: String? = null
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val bookRepository: BookRepository,
    private val sessionRepository: SessionRepository,
    private val goalRepository: GoalRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                // Load books
                val books = bookRepository.getUserBooks().first()

                // Calculate stats
                val booksRead = books.count { it.status == ReadingStatus.COMPLETED }
                val minutesToday = sessionRepository.getTotalReadingMinutesToday()
                val totalBooks = books.size

                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    allBooks = books,
                    stats = HomeStats(
                        booksRead = booksRead,
                        minutesToday = minutesToday,
                        currentStreak = 0, // TODO: Calculate streak
                        totalBooks = totalBooks
                    )
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load data"
                )
            }
        }
    }

    fun selectTab(index: Int) {
        _uiState.value = _uiState.value.copy(selectedTab = index)
    }

    fun getFilteredBooks(): List<UserBook> {
        val books = _uiState.value.allBooks
        return when (_uiState.value.selectedTab) {
            0 -> books // All
            1 -> books.filter { it.status == ReadingStatus.READING }
            2 -> books.filter { it.status == ReadingStatus.WANT_TO_READ }
            3 -> books.filter { it.status == ReadingStatus.COMPLETED }
            else -> books
        }
    }
}
