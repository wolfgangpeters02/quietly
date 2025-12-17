package com.quietly.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FormatQuote
import androidx.compose.material.icons.filled.Notes
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.quietly.app.data.model.Note
import com.quietly.app.data.model.NoteType
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles
import com.quietly.app.ui.theme.QuietlyTypography

@Composable
fun NoteCard(
    note: Note,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    showBookTitle: Boolean = false
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = QuietlyColors.Card
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = 2.dp
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            // Header with type badge
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                NoteTypeBadge(noteType = note.noteType)

                if (note.pageNumber != null) {
                    Text(
                        text = "Page ${note.pageNumber}",
                        style = QuietlyTextStyles.StatLabel,
                        modifier = Modifier.padding(start = 8.dp)
                    )
                }
            }

            // Note content
            if (note.noteType == NoteType.QUOTE) {
                Text(
                    text = "\"${note.content}\"",
                    style = QuietlyTextStyles.Quote.copy(fontStyle = FontStyle.Italic),
                    maxLines = 4,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(top = 12.dp)
                )
            } else {
                Text(
                    text = note.content,
                    style = QuietlyTypography.bodyMedium,
                    maxLines = 4,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(top = 12.dp)
                )
            }

            // Book title if showing
            if (showBookTitle && note.userBook?.book != null) {
                Text(
                    text = note.userBook.book.title,
                    style = QuietlyTextStyles.StatLabel.copy(color = QuietlyColors.Primary),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }
    }
}

@Composable
fun NoteTypeBadge(
    noteType: NoteType,
    modifier: Modifier = Modifier
) {
    val (icon, text, backgroundColor) = when (noteType) {
        NoteType.NOTE -> Triple(Icons.Default.Notes, "Note", QuietlyColors.Primary)
        NoteType.QUOTE -> Triple(Icons.Default.FormatQuote, "Quote", QuietlyColors.Accent)
    }

    Row(
        modifier = modifier
            .background(backgroundColor.copy(alpha = 0.15f), RoundedCornerShape(8.dp))
            .padding(horizontal = 8.dp, vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = backgroundColor,
            modifier = Modifier.padding(end = 4.dp)
        )
        Text(
            text = text,
            style = QuietlyTextStyles.StatLabel.copy(color = backgroundColor)
        )
    }
}
