package com.quietly.app.data.repository

import com.quietly.app.data.model.Note
import com.quietly.app.data.model.NoteType
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Columns
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.time.Instant
import java.util.UUID
import javax.inject.Inject

interface NoteRepository {
    fun getAllNotes(): Flow<List<Note>>
    fun getNotesForBook(userBookId: String): Flow<List<Note>>
    suspend fun getNote(id: String): Note?
    suspend fun createNote(
        userBookId: String,
        content: String,
        noteType: NoteType,
        pageNumber: Int?
    ): Result<Note>
    suspend fun updateNote(note: Note): Result<Note>
    suspend fun deleteNote(id: String): Result<Unit>
    suspend fun searchNotes(query: String): List<Note>
}

class NoteRepositoryImpl @Inject constructor(
    private val supabaseClient: SupabaseClient
) : NoteRepository {

    private val userId: String?
        get() = supabaseClient.auth.currentUserOrNull()?.id

    override fun getAllNotes(): Flow<List<Note>> = flow {
        val id = userId ?: throw Exception("User not authenticated")
        val notes = supabaseClient.postgrest["notes"]
            .select(Columns.raw("*, user_book:user_books(*, book:books(*))")) {
                filter {
                    eq("user_id", id)
                }
                order("created_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
            }
            .decodeList<Note>()
        emit(notes)
    }

    override fun getNotesForBook(userBookId: String): Flow<List<Note>> = flow {
        val notes = supabaseClient.postgrest["notes"]
            .select {
                filter {
                    eq("user_book_id", userBookId)
                }
                order("created_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
            }
            .decodeList<Note>()
        emit(notes)
    }

    override suspend fun getNote(id: String): Note? {
        return supabaseClient.postgrest["notes"]
            .select(Columns.raw("*, user_book:user_books(*, book:books(*))")) {
                filter {
                    eq("id", id)
                }
            }
            .decodeSingleOrNull<Note>()
    }

    override suspend fun createNote(
        userBookId: String,
        content: String,
        noteType: NoteType,
        pageNumber: Int?
    ): Result<Note> {
        return try {
            val id = userId ?: throw Exception("User not authenticated")
            val noteId = UUID.randomUUID().toString()
            val now = Instant.now().toString()

            val note = Note(
                id = noteId,
                userId = id,
                userBookId = userBookId,
                content = content,
                noteType = noteType,
                pageNumber = pageNumber,
                createdAt = now
            )

            supabaseClient.postgrest["notes"].insert(note)

            val result = getNote(noteId)
            if (result != null) {
                Result.success(result)
            } else {
                Result.failure(Exception("Failed to create note"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateNote(note: Note): Result<Note> {
        return try {
            val now = Instant.now().toString()
            supabaseClient.postgrest["notes"].update({
                set("content", note.content)
                set("note_type", note.noteType.name.lowercase())
                set("page_number", note.pageNumber)
                set("updated_at", now)
            }) {
                filter {
                    eq("id", note.id)
                }
            }

            val result = getNote(note.id)
            if (result != null) {
                Result.success(result)
            } else {
                Result.failure(Exception("Failed to update note"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun deleteNote(id: String): Result<Unit> {
        return try {
            supabaseClient.postgrest["notes"].delete {
                filter {
                    eq("id", id)
                }
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun searchNotes(query: String): List<Note> {
        val id = userId ?: return emptyList()
        return supabaseClient.postgrest["notes"]
            .select(Columns.raw("*, user_book:user_books(*, book:books(*))")) {
                filter {
                    eq("user_id", id)
                    ilike("content", "%$query%")
                }
                order("created_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
            }
            .decodeList<Note>()
    }
}
