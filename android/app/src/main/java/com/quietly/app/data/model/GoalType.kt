package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class GoalType {
    @SerialName("daily_minutes")
    DAILY_MINUTES,

    @SerialName("weekly_minutes")
    WEEKLY_MINUTES,

    @SerialName("books_per_month")
    BOOKS_PER_MONTH,

    @SerialName("books_per_year")
    BOOKS_PER_YEAR
}
