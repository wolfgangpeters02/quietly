package com.quietly.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Book
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.quietly.app.data.model.ReadingStatus
import com.quietly.app.data.model.UserBook
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles

@Composable
fun BookCard(
    userBook: UserBook,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val book = userBook.book ?: return

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
        Column {
            // Book cover
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(0.67f)
                    .clip(RoundedCornerShape(topStart = 12.dp, topEnd = 12.dp))
                    .background(QuietlyColors.SurfaceVariant)
            ) {
                if (!book.coverUrl.isNullOrEmpty()) {
                    AsyncImage(
                        model = book.coverUrl,
                        contentDescription = book.title,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Icon(
                        imageVector = Icons.Default.Book,
                        contentDescription = null,
                        modifier = Modifier
                            .size(48.dp)
                            .align(Alignment.Center),
                        tint = QuietlyColors.TextTertiary
                    )
                }

                // Status badge
                StatusBadge(
                    status = userBook.status,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                )
            }

            // Book info
            Column(
                modifier = Modifier.padding(12.dp)
            ) {
                Text(
                    text = book.title,
                    style = QuietlyTextStyles.BookTitle,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = book.author,
                    style = QuietlyTextStyles.BookAuthor,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(top = 4.dp)
                )

                // Progress bar for reading books
                if (userBook.status == ReadingStatus.READING && book.pageCount != null && book.pageCount > 0) {
                    val progress = userBook.currentPage.toFloat() / book.pageCount.toFloat()
                    LinearProgressIndicator(
                        progress = { progress.coerceIn(0f, 1f) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 8.dp)
                            .clip(RoundedCornerShape(4.dp)),
                        color = QuietlyColors.Accent,
                        trackColor = QuietlyColors.Divider
                    )
                    Text(
                        text = "${userBook.currentPage} / ${book.pageCount} pages",
                        style = QuietlyTextStyles.StatLabel,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun StatusBadge(
    status: ReadingStatus,
    modifier: Modifier = Modifier
) {
    val (backgroundColor, text) = when (status) {
        ReadingStatus.WANT_TO_READ -> QuietlyColors.WantToRead to "Want to Read"
        ReadingStatus.READING -> QuietlyColors.Reading to "Reading"
        ReadingStatus.COMPLETED -> QuietlyColors.Completed to "Completed"
    }

    Text(
        text = text,
        style = QuietlyTextStyles.StatLabel.copy(color = Color.White),
        modifier = modifier
            .background(backgroundColor, RoundedCornerShape(8.dp))
            .padding(horizontal = 8.dp, vertical = 4.dp)
    )
}
