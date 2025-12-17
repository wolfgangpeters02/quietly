package com.quietly.app.data.remote

import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.gotrue.Auth
import io.github.jan.supabase.postgrest.Postgrest

object SupabaseConfig {
    const val SUPABASE_URL = "https://vmfrjxodsgfjjigharxm.supabase.co"
    const val SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtZnJqeG9kc2dmamppZ2hhcnhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ0NDE4MzMsImV4cCI6MjA1MDAxNzgzM30.hSQHK4Twp6fjFuHYPfT-cdq1g37I4xY55CJq8XqvF-M"
}

fun createQuietlySupabaseClient(): SupabaseClient {
    return createSupabaseClient(
        supabaseUrl = SupabaseConfig.SUPABASE_URL,
        supabaseKey = SupabaseConfig.SUPABASE_ANON_KEY
    ) {
        install(Auth)
        install(Postgrest)
    }
}
