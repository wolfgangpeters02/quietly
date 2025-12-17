package com.quietly.app.data.repository

import com.quietly.app.data.model.ReadingSession
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.postgrest
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.time.Instant
import java.util.UUID
import javax.inject.Inject

interface SessionRepository {
    fun getSessionsForBook(userBookId: String): Flow<List<ReadingSession>>
    fun getRecentSessions(limit: Int = 10): Flow<List<ReadingSession>>
    suspend fun getActiveSession(): ReadingSession?
    suspend fun startSession(userBookId: String, startPage: Int?): Result<ReadingSession>
    suspend fun pauseSession(sessionId: String): Result<ReadingSession>
    suspend fun resumeSession(sessionId: String): Result<ReadingSession>
    suspend fun endSession(sessionId: String, endPage: Int?, notes: String?): Result<ReadingSession>
    suspend fun deleteSession(sessionId: String): Result<Unit>
    suspend fun getTotalReadingMinutesToday(): Int
    suspend fun getTotalReadingMinutesThisWeek(): Int
}

class SessionRepositoryImpl @Inject constructor(
    private val supabaseClient: SupabaseClient
) : SessionRepository {

    private val userId: String?
        get() = supabaseClient.auth.currentUserOrNull()?.id

    override fun getSessionsForBook(userBookId: String): Flow<List<ReadingSession>> = flow {
        val sessions = supabaseClient.postgrest["reading_sessions"]
            .select {
                filter {
                    eq("user_book_id", userBookId)
                }
                order("started_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
            }
            .decodeList<ReadingSession>()
        emit(sessions)
    }

    override fun getRecentSessions(limit: Int): Flow<List<ReadingSession>> = flow {
        val id = userId ?: throw Exception("User not authenticated")
        val sessions = supabaseClient.postgrest["reading_sessions"]
            .select {
                filter {
                    eq("user_id", id)
                    neq("ended_at", null)
                }
                order("ended_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
                limit(limit.toLong())
            }
            .decodeList<ReadingSession>()
        emit(sessions)
    }

    override suspend fun getActiveSession(): ReadingSession? {
        val id = userId ?: return null
        return supabaseClient.postgrest["reading_sessions"]
            .select {
                filter {
                    eq("user_id", id)
                    isNull("ended_at")
                }
            }
            .decodeSingleOrNull<ReadingSession>()
    }

    override suspend fun startSession(userBookId: String, startPage: Int?): Result<ReadingSession> {
        return try {
            val id = userId ?: throw Exception("User not authenticated")
            val sessionId = UUID.randomUUID().toString()
            val now = Instant.now().toString()

            val session = ReadingSession(
                id = sessionId,
                userId = id,
                userBookId = userBookId,
                startedAt = now,
                startPage = startPage,
                isPaused = false
            )

            supabaseClient.postgrest["reading_sessions"].insert(session)
            Result.success(session)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun pauseSession(sessionId: String): Result<ReadingSession> {
        return try {
            val now = Instant.now().toString()
            supabaseClient.postgrest["reading_sessions"].update({
                set("is_paused", true)
                set("paused_at", now)
            }) {
                filter {
                    eq("id", sessionId)
                }
            }
            val session = supabaseClient.postgrest["reading_sessions"]
                .select { filter { eq("id", sessionId) } }
                .decodeSingle<ReadingSession>()
            Result.success(session)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun resumeSession(sessionId: String): Result<ReadingSession> {
        return try {
            // Get current session to calculate paused time
            val currentSession = supabaseClient.postgrest["reading_sessions"]
                .select { filter { eq("id", sessionId) } }
                .decodeSingle<ReadingSession>()

            val pausedAt = currentSession.pausedAt?.let { Instant.parse(it) }
            val additionalPausedSeconds = if (pausedAt != null) {
                (Instant.now().epochSecond - pausedAt.epochSecond).toInt()
            } else 0

            val newTotalPaused = currentSession.totalPausedSeconds + additionalPausedSeconds

            supabaseClient.postgrest["reading_sessions"].update({
                set("is_paused", false)
                set("paused_at", null)
                set("total_paused_seconds", newTotalPaused)
            }) {
                filter {
                    eq("id", sessionId)
                }
            }

            val session = supabaseClient.postgrest["reading_sessions"]
                .select { filter { eq("id", sessionId) } }
                .decodeSingle<ReadingSession>()
            Result.success(session)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun endSession(sessionId: String, endPage: Int?, notes: String?): Result<ReadingSession> {
        return try {
            val currentSession = supabaseClient.postgrest["reading_sessions"]
                .select { filter { eq("id", sessionId) } }
                .decodeSingle<ReadingSession>()

            val now = Instant.now()
            val startedAt = Instant.parse(currentSession.startedAt)

            // Calculate total duration minus paused time
            var totalPaused = currentSession.totalPausedSeconds
            if (currentSession.isPaused && currentSession.pausedAt != null) {
                val pausedAt = Instant.parse(currentSession.pausedAt)
                totalPaused += (now.epochSecond - pausedAt.epochSecond).toInt()
            }

            val totalSeconds = (now.epochSecond - startedAt.epochSecond).toInt() - totalPaused
            val pagesRead = if (endPage != null && currentSession.startPage != null) {
                endPage - currentSession.startPage
            } else null

            supabaseClient.postgrest["reading_sessions"].update({
                set("ended_at", now.toString())
                set("duration_seconds", totalSeconds)
                set("end_page", endPage)
                set("pages_read", pagesRead)
                set("notes", notes)
                set("is_paused", false)
                set("paused_at", null)
                set("total_paused_seconds", totalPaused)
            }) {
                filter {
                    eq("id", sessionId)
                }
            }

            val session = supabaseClient.postgrest["reading_sessions"]
                .select { filter { eq("id", sessionId) } }
                .decodeSingle<ReadingSession>()
            Result.success(session)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun deleteSession(sessionId: String): Result<Unit> {
        return try {
            supabaseClient.postgrest["reading_sessions"].delete {
                filter {
                    eq("id", sessionId)
                }
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun getTotalReadingMinutesToday(): Int {
        val id = userId ?: return 0
        val todayStart = java.time.LocalDate.now().atStartOfDay(java.time.ZoneOffset.UTC).toInstant().toString()

        val sessions = supabaseClient.postgrest["reading_sessions"]
            .select {
                filter {
                    eq("user_id", id)
                    gte("started_at", todayStart)
                    neq("ended_at", null)
                }
            }
            .decodeList<ReadingSession>()

        return sessions.sumOf { it.durationSeconds ?: 0 } / 60
    }

    override suspend fun getTotalReadingMinutesThisWeek(): Int {
        val id = userId ?: return 0
        val weekStart = java.time.LocalDate.now()
            .with(java.time.DayOfWeek.MONDAY)
            .atStartOfDay(java.time.ZoneOffset.UTC)
            .toInstant()
            .toString()

        val sessions = supabaseClient.postgrest["reading_sessions"]
            .select {
                filter {
                    eq("user_id", id)
                    gte("started_at", weekStart)
                    neq("ended_at", null)
                }
            }
            .decodeList<ReadingSession>()

        return sessions.sumOf { it.durationSeconds ?: 0 } / 60
    }
}
