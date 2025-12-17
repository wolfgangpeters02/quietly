package com.quietly.app.ui.screens.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.quietly.app.data.model.Book
import com.quietly.app.data.model.ReadingStatus
import com.quietly.app.data.remote.OpenLibraryApi
import com.quietly.app.data.remote.OpenLibraryDoc
import com.quietly.app.data.repository.BookRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AddBookUiState(
    val searchQuery: String = "",
    val isSearching: Boolean = false,
    val searchResults: List<OpenLibraryDoc> = emptyList(),
    val selectedResult: OpenLibraryDoc? = null,
    val isbn: String = "",
    val isbnBook: Book? = null,
    val manualTitle: String = "",
    val manualAuthor: String = "",
    val manualPageCount: String = "",
    val error: String? = null
)

@HiltViewModel
class AddBookViewModel @Inject constructor(
    private val bookRepository: BookRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AddBookUiState())
    val uiState: StateFlow<AddBookUiState> = _uiState.asStateFlow()

    fun updateSearchQuery(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query, error = null)
    }

    fun searchBooks() {
        val query = _uiState.value.searchQuery
        if (query.isBlank()) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSearching = true, error = null)
            val result = bookRepository.searchBooks(query)
            result.fold(
                onSuccess = { docs ->
                    _uiState.value = _uiState.value.copy(
                        isSearching = false,
                        searchResults = docs
                    )
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        isSearching = false,
                        error = e.message ?: "Search failed"
                    )
                }
            )
        }
    }

    fun selectSearchResult(doc: OpenLibraryDoc) {
        _uiState.value = _uiState.value.copy(selectedResult = doc)
    }

    fun addSelectedBook(status: ReadingStatus) {
        val doc = _uiState.value.selectedResult ?: return

        viewModelScope.launch {
            val book = Book(
                id = "",
                title = doc.title ?: "Unknown",
                author = doc.author_name?.firstOrNull() ?: "Unknown",
                isbn = doc.isbn?.firstOrNull(),
                coverUrl = OpenLibraryApi.getCoverUrl(doc.cover_i),
                pageCount = doc.number_of_pages_median,
                publishedDate = doc.first_publish_year?.toString(),
                publisher = doc.publisher?.firstOrNull(),
                openLibraryKey = doc.key
            )

            val result = bookRepository.addBook(book, status)
            result.fold(
                onSuccess = { /* Success handled by UI */ },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to add book"
                    )
                }
            )
        }
    }

    fun updateISBN(isbn: String) {
        _uiState.value = _uiState.value.copy(isbn = isbn, error = null, isbnBook = null)
    }

    fun lookupISBN() {
        val isbn = _uiState.value.isbn.replace("-", "").trim()
        if (isbn.isBlank()) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSearching = true, error = null)
            val result = bookRepository.getBookByISBN(isbn)
            result.fold(
                onSuccess = { book ->
                    _uiState.value = _uiState.value.copy(
                        isSearching = false,
                        isbnBook = book
                    )
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        isSearching = false,
                        error = "Book not found. Please check the ISBN."
                    )
                }
            )
        }
    }

    fun addISBNBook(status: ReadingStatus) {
        val book = _uiState.value.isbnBook ?: return

        viewModelScope.launch {
            val result = bookRepository.addBook(book, status)
            result.fold(
                onSuccess = { /* Success handled by UI */ },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to add book"
                    )
                }
            )
        }
    }

    fun updateManualTitle(title: String) {
        _uiState.value = _uiState.value.copy(manualTitle = title, error = null)
    }

    fun updateManualAuthor(author: String) {
        _uiState.value = _uiState.value.copy(manualAuthor = author, error = null)
    }

    fun updateManualPageCount(pageCount: String) {
        _uiState.value = _uiState.value.copy(manualPageCount = pageCount, error = null)
    }

    fun addManualBook(status: ReadingStatus) {
        val state = _uiState.value
        if (state.manualTitle.isBlank() || state.manualAuthor.isBlank()) return

        viewModelScope.launch {
            val book = Book(
                id = "",
                title = state.manualTitle,
                author = state.manualAuthor,
                pageCount = state.manualPageCount.toIntOrNull()
            )

            val result = bookRepository.addBook(book, status)
            result.fold(
                onSuccess = { /* Success handled by UI */ },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to add book"
                    )
                }
            )
        }
    }

    fun clearState() {
        _uiState.value = AddBookUiState()
    }
}
