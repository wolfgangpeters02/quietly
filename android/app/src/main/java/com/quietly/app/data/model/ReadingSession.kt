package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ReadingSession(
    val id: String,
    @SerialName("user_id")
    val userId: String,
    @SerialName("user_book_id")
    val userBookId: String,
    @SerialName("started_at")
    val startedAt: String,
    @SerialName("ended_at")
    val endedAt: String? = null,
    @SerialName("duration_seconds")
    val durationSeconds: Int? = null,
    @SerialName("pages_read")
    val pagesRead: Int? = null,
    @SerialName("start_page")
    val startPage: Int? = null,
    @SerialName("end_page")
    val endPage: Int? = null,
    val notes: String? = null,
    @SerialName("is_paused")
    val isPaused: Boolean = false,
    @SerialName("paused_at")
    val pausedAt: String? = null,
    @SerialName("total_paused_seconds")
    val totalPausedSeconds: Int = 0,
    @SerialName("created_at")
    val createdAt: String? = null
)
