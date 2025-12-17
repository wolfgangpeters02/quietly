package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ReadingGoal(
    val id: String,
    @SerialName("user_id")
    val userId: String,
    @SerialName("goal_type")
    val goalType: GoalType,
    @SerialName("target_value")
    val targetValue: Int,
    @SerialName("current_value")
    val currentValue: Int = 0,
    @SerialName("start_date")
    val startDate: String,
    @SerialName("end_date")
    val endDate: String? = null,
    @SerialName("is_active")
    val isActive: Boolean = true,
    @SerialName("created_at")
    val createdAt: String? = null,
    @SerialName("updated_at")
    val updatedAt: String? = null
)
