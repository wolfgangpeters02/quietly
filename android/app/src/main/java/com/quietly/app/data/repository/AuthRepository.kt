package com.quietly.app.data.repository

import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.gotrue.providers.builtin.Email
import io.github.jan.supabase.gotrue.user.UserInfo
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

interface AuthRepository {
    val currentUser: Flow<UserInfo?>
    val isAuthenticated: Flow<Boolean>
    suspend fun signIn(email: String, password: String): Result<UserInfo>
    suspend fun signUp(email: String, password: String): Result<UserInfo>
    suspend fun signOut(): Result<Unit>
    fun getCurrentUserId(): String?
}

class AuthRepositoryImpl @Inject constructor(
    private val supabaseClient: SupabaseClient
) : AuthRepository {

    override val currentUser: Flow<UserInfo?>
        get() = supabaseClient.auth.sessionStatus.map { status ->
            when (status) {
                is io.github.jan.supabase.gotrue.SessionStatus.Authenticated -> status.session.user
                else -> null
            }
        }

    override val isAuthenticated: Flow<Boolean>
        get() = currentUser.map { it != null }

    override suspend fun signIn(email: String, password: String): Result<UserInfo> {
        return try {
            supabaseClient.auth.signInWith(Email) {
                this.email = email
                this.password = password
            }
            val user = supabaseClient.auth.currentUserOrNull()
            if (user != null) {
                Result.success(user)
            } else {
                Result.failure(Exception("Sign in failed"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun signUp(email: String, password: String): Result<UserInfo> {
        return try {
            supabaseClient.auth.signUpWith(Email) {
                this.email = email
                this.password = password
            }
            val user = supabaseClient.auth.currentUserOrNull()
            if (user != null) {
                Result.success(user)
            } else {
                Result.failure(Exception("Sign up failed"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override suspend fun signOut(): Result<Unit> {
        return try {
            supabaseClient.auth.signOut()
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    override fun getCurrentUserId(): String? {
        return supabaseClient.auth.currentUserOrNull()?.id
    }
}
