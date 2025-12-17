package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class UserBook(
    val id: String,
    @SerialName("user_id")
    val userId: String,
    @SerialName("book_id")
    val bookId: String,
    val status: ReadingStatus,
    @SerialName("current_page")
    val currentPage: Int = 0,
    val rating: Int? = null,
    @SerialName("started_at")
    val startedAt: String? = null,
    @SerialName("finished_at")
    val finishedAt: String? = null,
    @SerialName("created_at")
    val createdAt: String? = null,
    @SerialName("updated_at")
    val updatedAt: String? = null,
    // Joined data
    val book: Book? = null
)
