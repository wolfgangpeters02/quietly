package com.quietly.app.data.repository

import com.quietly.app.data.model.Book
import com.quietly.app.data.model.ReadingStatus
import com.quietly.app.data.model.UserBook
import com.quietly.app.data.remote.OpenLibraryApi
import com.quietly.app.data.remote.OpenLibraryDoc
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Columns
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.util.UUID
import javax.inject.Inject

interface BookRepository {
    fun getUserBooks(): Flow<List<UserBook>>
    fun getUserBooksByStatus(status: ReadingStatus): Flow<List<UserBook>>
    suspend fun getUserBook(id: String): UserBook?
    suspend fun addBook(book: Book, status: ReadingStatus): Result<UserBook>
    suspend fun updateUserBook(userBook: UserBook): Result<UserBook>
    suspend fun deleteUserBook(id: String): Result<Unit>
    suspend fun searchBooks(query: String): Result<List<OpenLibraryDoc>>
    suspend fun getBookByISBN(isbn: String): Result<Book?>
}

class BookRepositoryImpl @Inject constructor(
    private val supabaseClient: SupabaseClient,
    private val openLibraryApi: OpenLibraryApi
) : BookRepository {

    private val userId: String?
        get() = supabaseClient.auth.currentUserOrNull()?.id

    override fun getUserBooks(): Flow<List<UserBook>> = flow {
        val id = userId ?: throw Exception("User not authenticated")
        val userBooks = supabaseClient.postgrest["user_books"]
            .select(Columns.raw("*, book:books(*)")) {
                filter {
                    eq("user_id", id)
                }
            }
            .decodeList<UserBook>()
        emit(userBooks)
    }

    override fun getUserBooksByStatus(status: ReadingStatus): Flow<List<UserBook>> = flow {
        val id = userId ?: throw Exception("User not authenticated")
        val userBooks = supabaseClient.postgrest["user_books"]
            .select(Columns.raw("*, book:books(*)")) {
                filter {
                    eq("user_id", id)
                    eq("status", status.name.lowercase())
                }
            }
            .decodeList<UserBook>()
        emit(userBooks)
    }

    override suspend fun getUserBook(id: String): UserBook? {
        return supabaseClient.postgrest["user_books"]
            .select(Columns.raw("*, book:books(*)")) {
                filter {
                    eq("id", id)
                }
            }
            .decodeSingleOrNull<UserBook>()
    }

    override suspend fun addBook(book: Book, status: ReadingStatus): Result<UserBook> {
        return try {
            val id = userId ?: throw Exception("User not authenticated")

            // First, insert the book
            val bookId = book.id.ifEmpty { UUID.randomUUID().toString() }
            val bookToInsert = book.copy(id = bookId)

            supabaseClient.postgrest["books"].upsert(bookToInsert)

            // Then create user_book entry
            val userBookId = UUID.randomUUID().toString()
            val userBook = UserBook(
                id = userBookId,
                userId = id,
                bookId = bookId,
                status = status
            )

            supabaseClient.postgrest["user_books"].insert(userBook)

            val result = getUserBook(userBookId)
            if (result != null) {
                Result.success(result)
            } else {
                Result.failure(Exception("Failed to create user book"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateUserBook(userBook: UserBook): Result<UserBook> {
        return try {
            supabaseClient.postgrest["user_books"].update(userBook) {
                filter {
                    eq("id", userBook.id)
                }
            }
            val result = getUserBook(userBook.id)
            if (result != null) {
                Result.success(result)
            } else {
                Result.failure(Exception("Failed to update user book"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun deleteUserBook(id: String): Result<Unit> {
        return try {
            supabaseClient.postgrest["user_books"].delete {
                filter {
                    eq("id", id)
                }
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun searchBooks(query: String): Result<List<OpenLibraryDoc>> {
        return try {
            val response = openLibraryApi.searchBooks(query)
            Result.success(response.docs)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getBookByISBN(isbn: String): Result<Book?> {
        return try {
            val response = openLibraryApi.getByISBN(isbn)
            val book = Book(
                id = "",
                title = response.title ?: "Unknown",
                author = response.authors?.firstOrNull()?.name ?: "Unknown",
                isbn = isbn,
                coverUrl = response.covers?.firstOrNull()?.let { OpenLibraryApi.getCoverUrl(it) },
                pageCount = response.number_of_pages,
                publishedDate = response.publish_date,
                publisher = response.publishers?.firstOrNull(),
                openLibraryKey = response.works?.firstOrNull()?.key
            )
            Result.success(book)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
