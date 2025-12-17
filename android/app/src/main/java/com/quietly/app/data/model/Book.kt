package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Book(
    val id: String,
    val title: String,
    val author: String,
    val isbn: String? = null,
    @SerialName("cover_url")
    val coverUrl: String? = null,
    @SerialName("page_count")
    val pageCount: Int? = null,
    val description: String? = null,
    @SerialName("published_date")
    val publishedDate: String? = null,
    val publisher: String? = null,
    @SerialName("open_library_key")
    val openLibraryKey: String? = null,
    @SerialName("created_at")
    val createdAt: String? = null
)
