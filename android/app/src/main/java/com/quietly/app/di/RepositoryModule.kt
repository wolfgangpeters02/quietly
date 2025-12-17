package com.quietly.app.di

import com.quietly.app.data.remote.OpenLibraryApi
import com.quietly.app.data.repository.AuthRepository
import com.quietly.app.data.repository.AuthRepositoryImpl
import com.quietly.app.data.repository.BookRepository
import com.quietly.app.data.repository.BookRepositoryImpl
import com.quietly.app.data.repository.GoalRepository
import com.quietly.app.data.repository.GoalRepositoryImpl
import com.quietly.app.data.repository.NoteRepository
import com.quietly.app.data.repository.NoteRepositoryImpl
import com.quietly.app.data.repository.SessionRepository
import com.quietly.app.data.repository.SessionRepositoryImpl
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import io.github.jan.supabase.SupabaseClient
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {

    @Provides
    @Singleton
    fun provideAuthRepository(supabaseClient: SupabaseClient): AuthRepository {
        return AuthRepositoryImpl(supabaseClient)
    }

    @Provides
    @Singleton
    fun provideBookRepository(
        supabaseClient: SupabaseClient,
        openLibraryApi: OpenLibraryApi
    ): BookRepository {
        return BookRepositoryImpl(supabaseClient, openLibraryApi)
    }

    @Provides
    @Singleton
    fun provideSessionRepository(supabaseClient: SupabaseClient): SessionRepository {
        return SessionRepositoryImpl(supabaseClient)
    }

    @Provides
    @Singleton
    fun provideNoteRepository(supabaseClient: SupabaseClient): NoteRepository {
        return NoteRepositoryImpl(supabaseClient)
    }

    @Provides
    @Singleton
    fun provideGoalRepository(supabaseClient: SupabaseClient): GoalRepository {
        return GoalRepositoryImpl(supabaseClient)
    }
}
