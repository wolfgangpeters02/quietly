package com.quietly.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.rememberNavController
import com.quietly.app.ui.navigation.QuietlyNavGraph
import com.quietly.app.ui.navigation.Route
import com.quietly.app.ui.screens.auth.AuthViewModel
import com.quietly.app.ui.theme.QuietlyTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            QuietlyTheme {
                val navController = rememberNavController()
                val authViewModel: AuthViewModel = hiltViewModel()
                val authState by authViewModel.uiState.collectAsState()

                // Determine start destination based on auth state
                val startDestination = if (authState.isAuthenticated) {
                    Route.Home.route
                } else {
                    Route.Auth.route
                }

                QuietlyNavGraph(
                    navController = navController,
                    startDestination = startDestination
                )
            }
        }
    }
}
