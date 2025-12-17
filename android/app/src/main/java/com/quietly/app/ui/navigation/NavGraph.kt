package com.quietly.app.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.Flag
import androidx.compose.material.icons.filled.Notes
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.quietly.app.ui.screens.auth.AuthScreen
import com.quietly.app.ui.screens.book.BookDetailScreen
import com.quietly.app.ui.screens.goals.GoalsScreen
import com.quietly.app.ui.screens.home.AddBookSheet
import com.quietly.app.ui.screens.home.HomeScreen
import com.quietly.app.ui.screens.notes.NotesScreen
import com.quietly.app.ui.screens.session.ReadingSessionScreen
import com.quietly.app.ui.screens.settings.SettingsScreen
import com.quietly.app.ui.theme.QuietlyColors

data class BottomNavItem(
    val route: String,
    val icon: ImageVector,
    val label: String
)

val bottomNavItems = listOf(
    BottomNavItem(Route.Home.route, Icons.Default.Book, "Library"),
    BottomNavItem(Route.Goals.route, Icons.Default.Flag, "Goals"),
    BottomNavItem(Route.Notes.route, Icons.Default.Notes, "Notes"),
    BottomNavItem(Route.Settings.route, Icons.Default.Settings, "Settings")
)

@Composable
fun QuietlyNavGraph(
    navController: NavHostController = rememberNavController(),
    startDestination: String = Route.Auth.route
) {
    var showAddBookSheet by remember { mutableStateOf(false) }

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    val showBottomBar = currentRoute in bottomNavItems.map { it.route }

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(
                    containerColor = QuietlyColors.Card
                ) {
                    bottomNavItems.forEach { item ->
                        NavigationBarItem(
                            icon = { Icon(item.icon, contentDescription = item.label) },
                            label = { Text(item.label) },
                            selected = currentRoute == item.route,
                            onClick = {
                                if (currentRoute != item.route) {
                                    navController.navigate(item.route) {
                                        popUpTo(Route.Home.route) {
                                            saveState = true
                                        }
                                        launchSingleTop = true
                                        restoreState = true
                                    }
                                }
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = QuietlyColors.Primary,
                                selectedTextColor = QuietlyColors.Primary,
                                unselectedIconColor = QuietlyColors.TextSecondary,
                                unselectedTextColor = QuietlyColors.TextSecondary,
                                indicatorColor = QuietlyColors.Primary.copy(alpha = 0.1f)
                            )
                        )
                    }
                }
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = startDestination,
            modifier = Modifier.padding(padding)
        ) {
            composable(Route.Auth.route) {
                AuthScreen(
                    onAuthenticated = {
                        navController.navigate(Route.Home.route) {
                            popUpTo(Route.Auth.route) { inclusive = true }
                        }
                    }
                )
            }

            composable(Route.Home.route) {
                HomeScreen(
                    onBookClick = { userBookId ->
                        navController.navigate(Route.BookDetail.createRoute(userBookId))
                    },
                    onAddBook = { showAddBookSheet = true }
                )
            }

            composable(
                route = Route.BookDetail.route,
                arguments = listOf(navArgument("userBookId") { type = NavType.StringType })
            ) {
                BookDetailScreen(
                    onBack = { navController.popBackStack() },
                    onStartReading = { userBookId ->
                        navController.navigate(Route.ReadingSession.createRoute(userBookId))
                    },
                    onAddNote = { /* Could open note dialog */ }
                )
            }

            composable(
                route = Route.ReadingSession.route,
                arguments = listOf(navArgument("userBookId") { type = NavType.StringType })
            ) {
                ReadingSessionScreen(
                    onBack = { navController.popBackStack() },
                    onSessionEnded = { navController.popBackStack() }
                )
            }

            composable(Route.Goals.route) {
                GoalsScreen()
            }

            composable(Route.Notes.route) {
                NotesScreen()
            }

            composable(Route.Settings.route) {
                SettingsScreen(
                    onSignOut = {
                        navController.navigate(Route.Auth.route) {
                            popUpTo(0) { inclusive = true }
                        }
                    },
                    onNotifications = {
                        navController.navigate(Route.Notifications.route)
                    }
                )
            }

            composable(Route.Notifications.route) {
                // Notifications screen - placeholder for now
                Text("Notifications")
            }
        }

        // Add Book Sheet
        if (showAddBookSheet) {
            AddBookSheet(
                onDismiss = { showAddBookSheet = false },
                onBookAdded = {
                    showAddBookSheet = false
                    // Refresh home screen
                }
            )
        }
    }
}
