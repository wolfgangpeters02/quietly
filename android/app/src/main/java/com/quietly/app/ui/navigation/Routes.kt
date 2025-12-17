package com.quietly.app.ui.navigation

sealed class Route(val route: String) {
    object Auth : Route("auth")
    object Home : Route("home")
    object BookDetail : Route("book/{userBookId}") {
        fun createRoute(userBookId: String) = "book/$userBookId"
    }
    object ReadingSession : Route("session/{userBookId}") {
        fun createRoute(userBookId: String) = "session/$userBookId"
    }
    object Goals : Route("goals")
    object Notes : Route("notes")
    object Settings : Route("settings")
    object Notifications : Route("notifications")
}
