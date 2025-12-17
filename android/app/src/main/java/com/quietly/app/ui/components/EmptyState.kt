package com.quietly.app.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.Note
import androidx.compose.material.icons.filled.Flag
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTypography

@Composable
fun EmptyState(
    icon: ImageVector,
    title: String,
    message: String,
    actionLabel: String? = null,
    onAction: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            modifier = Modifier.size(80.dp),
            tint = QuietlyColors.TextTertiary
        )
        Text(
            text = title,
            style = QuietlyTypography.headlineSmall,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(top = 24.dp)
        )
        Text(
            text = message,
            style = QuietlyTypography.bodyMedium,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(top = 8.dp)
        )
        if (actionLabel != null && onAction != null) {
            Button(
                onClick = onAction,
                modifier = Modifier.padding(top = 24.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = QuietlyColors.Primary
                )
            ) {
                Text(text = actionLabel)
            }
        }
    }
}

object EmptyStates {
    @Composable
    fun NoBooks(onAddBook: () -> Unit) {
        EmptyState(
            icon = Icons.Default.Book,
            title = "No books yet",
            message = "Start your reading journey by adding your first book.",
            actionLabel = "Add Book",
            onAction = onAddBook
        )
    }

    @Composable
    fun NoNotes(onAddNote: (() -> Unit)? = null) {
        EmptyState(
            icon = Icons.Default.Note,
            title = "No notes yet",
            message = "Capture your thoughts and favorite quotes while reading.",
            actionLabel = if (onAddNote != null) "Add Note" else null,
            onAction = onAddNote
        )
    }

    @Composable
    fun NoGoals(onAddGoal: () -> Unit) {
        EmptyState(
            icon = Icons.Default.Flag,
            title = "No goals yet",
            message = "Set reading goals to track your progress and stay motivated.",
            actionLabel = "Add Goal",
            onAction = onAddGoal
        )
    }

    @Composable
    fun NoSearchResults() {
        EmptyState(
            icon = Icons.Default.Search,
            title = "No results found",
            message = "Try adjusting your search terms or filters."
        )
    }
}
