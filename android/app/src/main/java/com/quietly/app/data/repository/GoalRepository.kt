package com.quietly.app.data.repository

import com.quietly.app.data.model.GoalType
import com.quietly.app.data.model.ReadingGoal
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.postgrest
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.time.DayOfWeek
import java.time.Instant
import java.time.LocalDate
import java.time.YearMonth
import java.time.ZoneOffset
import java.util.UUID
import javax.inject.Inject

interface GoalRepository {
    fun getActiveGoals(): Flow<List<ReadingGoal>>
    fun getAllGoals(): Flow<List<ReadingGoal>>
    suspend fun getGoal(id: String): ReadingGoal?
    suspend fun createGoal(goalType: GoalType, targetValue: Int): Result<ReadingGoal>
    suspend fun updateGoal(goal: ReadingGoal): Result<ReadingGoal>
    suspend fun deleteGoal(id: String): Result<Unit>
    suspend fun calculateGoalProgress(goal: ReadingGoal): Int
}

class GoalRepositoryImpl @Inject constructor(
    private val supabaseClient: SupabaseClient
) : GoalRepository {

    private val userId: String?
        get() = supabaseClient.auth.currentUserOrNull()?.id

    override fun getActiveGoals(): Flow<List<ReadingGoal>> = flow {
        val id = userId ?: throw Exception("User not authenticated")
        val goals = supabaseClient.postgrest["reading_goals"]
            .select {
                filter {
                    eq("user_id", id)
                    eq("is_active", true)
                }
                order("created_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
            }
            .decodeList<ReadingGoal>()

        // Calculate current progress for each goal
        val goalsWithProgress = goals.map { goal ->
            val progress = calculateGoalProgress(goal)
            goal.copy(currentValue = progress)
        }
        emit(goalsWithProgress)
    }

    override fun getAllGoals(): Flow<List<ReadingGoal>> = flow {
        val id = userId ?: throw Exception("User not authenticated")
        val goals = supabaseClient.postgrest["reading_goals"]
            .select {
                filter {
                    eq("user_id", id)
                }
                order("created_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
            }
            .decodeList<ReadingGoal>()
        emit(goals)
    }

    override suspend fun getGoal(id: String): ReadingGoal? {
        return supabaseClient.postgrest["reading_goals"]
            .select {
                filter {
                    eq("id", id)
                }
            }
            .decodeSingleOrNull<ReadingGoal>()
    }

    override suspend fun createGoal(goalType: GoalType, targetValue: Int): Result<ReadingGoal> {
        return try {
            val id = userId ?: throw Exception("User not authenticated")
            val goalId = UUID.randomUUID().toString()
            val now = Instant.now().toString()
            val today = LocalDate.now()

            val (startDate, endDate) = when (goalType) {
                GoalType.DAILY_MINUTES -> {
                    val start = today.atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    val end = today.plusDays(1).atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    start to end
                }
                GoalType.WEEKLY_MINUTES -> {
                    val start = today.with(DayOfWeek.MONDAY).atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    val end = today.with(DayOfWeek.SUNDAY).plusDays(1).atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    start to end
                }
                GoalType.BOOKS_PER_MONTH -> {
                    val yearMonth = YearMonth.from(today)
                    val start = yearMonth.atDay(1).atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    val end = yearMonth.atEndOfMonth().plusDays(1).atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    start to end
                }
                GoalType.BOOKS_PER_YEAR -> {
                    val start = today.withDayOfYear(1).atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    val end = today.withDayOfYear(1).plusYears(1).atStartOfDay(ZoneOffset.UTC).toInstant().toString()
                    start to end
                }
            }

            val goal = ReadingGoal(
                id = goalId,
                userId = id,
                goalType = goalType,
                targetValue = targetValue,
                currentValue = 0,
                startDate = startDate,
                endDate = endDate,
                isActive = true,
                createdAt = now
            )

            supabaseClient.postgrest["reading_goals"].insert(goal)
            Result.success(goal)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun updateGoal(goal: ReadingGoal): Result<ReadingGoal> {
        return try {
            val now = Instant.now().toString()
            supabaseClient.postgrest["reading_goals"].update({
                set("target_value", goal.targetValue)
                set("is_active", goal.isActive)
                set("updated_at", now)
            }) {
                filter {
                    eq("id", goal.id)
                }
            }

            val result = getGoal(goal.id)
            if (result != null) {
                Result.success(result)
            } else {
                Result.failure(Exception("Failed to update goal"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun deleteGoal(id: String): Result<Unit> {
        return try {
            supabaseClient.postgrest["reading_goals"].delete {
                filter {
                    eq("id", id)
                }
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun calculateGoalProgress(goal: ReadingGoal): Int {
        val id = userId ?: return 0

        return when (goal.goalType) {
            GoalType.DAILY_MINUTES, GoalType.WEEKLY_MINUTES -> {
                // Sum reading session durations in the period
                val sessions = supabaseClient.postgrest["reading_sessions"]
                    .select {
                        filter {
                            eq("user_id", id)
                            gte("started_at", goal.startDate)
                            goal.endDate?.let { lte("ended_at", it) }
                            neq("ended_at", null)
                        }
                    }
                    .decodeList<com.quietly.app.data.model.ReadingSession>()

                sessions.sumOf { it.durationSeconds ?: 0 } / 60
            }
            GoalType.BOOKS_PER_MONTH, GoalType.BOOKS_PER_YEAR -> {
                // Count completed books in the period
                val userBooks = supabaseClient.postgrest["user_books"]
                    .select {
                        filter {
                            eq("user_id", id)
                            eq("status", "completed")
                            gte("finished_at", goal.startDate)
                            goal.endDate?.let { lte("finished_at", it) }
                        }
                    }
                    .decodeList<com.quietly.app.data.model.UserBook>()

                userBooks.size
            }
        }
    }
}
