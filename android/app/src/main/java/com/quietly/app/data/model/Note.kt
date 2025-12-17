package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Note(
    val id: String,
    @SerialName("user_id")
    val userId: String,
    @SerialName("user_book_id")
    val userBookId: String,
    val content: String,
    @SerialName("note_type")
    val noteType: NoteType = NoteType.NOTE,
    @SerialName("page_number")
    val pageNumber: Int? = null,
    @SerialName("created_at")
    val createdAt: String? = null,
    @SerialName("updated_at")
    val updatedAt: String? = null,
    // Joined data
    @SerialName("user_book")
    val userBook: UserBook? = null
)
