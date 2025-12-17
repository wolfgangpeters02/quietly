package com.quietly.app.ui.screens.book

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.quietly.app.data.model.ReadingStatus
import com.quietly.app.ui.components.LoadingIndicator
import com.quietly.app.ui.components.NoteCard
import com.quietly.app.ui.components.StarRating
import com.quietly.app.ui.components.StatItem
import com.quietly.app.ui.components.StatsCard
import com.quietly.app.ui.components.StatusBadge
import com.quietly.app.ui.components.formatDuration
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles
import com.quietly.app.ui.theme.QuietlyTypography

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookDetailScreen(
    onBack: () -> Unit,
    onStartReading: (String) -> Unit,
    onAddNote: (String) -> Unit,
    viewModel: BookDetailViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showMenu by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Book Details") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(onClick = { showMenu = true }) {
                        Icon(Icons.Default.MoreVert, contentDescription = "More")
                    }
                    DropdownMenu(
                        expanded = showMenu,
                        onDismissRequest = { showMenu = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("Delete Book") },
                            leadingIcon = { Icon(Icons.Default.Delete, null, tint = QuietlyColors.Error) },
                            onClick = {
                                showMenu = false
                                viewModel.deleteBook()
                                onBack()
                            }
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = QuietlyColors.Background
                )
            )
        },
        containerColor = QuietlyColors.Background
    ) { padding ->
        if (uiState.isLoading) {
            LoadingIndicator()
        } else if (uiState.userBook == null) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text("Book not found", style = QuietlyTypography.bodyLarge)
            }
        } else {
            val userBook = uiState.userBook!!
            val book = userBook.book!!

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp)
            ) {
                // Book Header
                Row {
                    // Cover
                    Box(
                        modifier = Modifier
                            .width(120.dp)
                            .aspectRatio(0.67f)
                            .clip(RoundedCornerShape(8.dp))
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
                                Icons.Default.Book,
                                contentDescription = null,
                                modifier = Modifier
                                    .size(48.dp)
                                    .align(Alignment.Center),
                                tint = QuietlyColors.TextTertiary
                            )
                        }
                    }

                    Spacer(modifier = Modifier.width(16.dp))

                    // Book info
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = book.title,
                            style = QuietlyTypography.headlineSmall,
                            maxLines = 3,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = book.author,
                            style = QuietlyTextStyles.BookAuthor,
                            modifier = Modifier.padding(top = 4.dp)
                        )

                        StatusBadge(
                            status = userBook.status,
                            modifier = Modifier.padding(top = 8.dp)
                        )

                        // Rating
                        StarRating(
                            rating = userBook.rating ?: 0,
                            onRatingChanged = { viewModel.updateRating(it) },
                            modifier = Modifier.padding(top = 8.dp)
                        )

                        if (book.pageCount != null) {
                            Text(
                                text = "${book.pageCount} pages",
                                style = QuietlyTextStyles.StatLabel,
                                modifier = Modifier.padding(top = 4.dp)
                            )
                        }
                    }
                }

                // Progress section (for books being read)
                if (userBook.status == ReadingStatus.READING && book.pageCount != null && book.pageCount > 0) {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 16.dp),
                        colors = CardDefaults.cardColors(containerColor = QuietlyColors.Card)
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text("Progress", style = QuietlyTypography.titleMedium)

                            val progress = userBook.currentPage.toFloat() / book.pageCount.toFloat()
                            LinearProgressIndicator(
                                progress = { progress.coerceIn(0f, 1f) },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(top = 12.dp)
                                    .height(8.dp)
                                    .clip(RoundedCornerShape(4.dp)),
                                color = QuietlyColors.Accent,
                                trackColor = QuietlyColors.Divider
                            )
                            Text(
                                text = "${userBook.currentPage} / ${book.pageCount} pages (${(progress * 100).toInt()}%)",
                                style = QuietlyTextStyles.StatLabel,
                                modifier = Modifier.padding(top = 4.dp)
                            )
                        }
                    }
                }

                // Stats Card
                StatsCard(
                    stats = listOf(
                        StatItem(uiState.sessions.size.toString(), "Sessions"),
                        StatItem(formatDuration(uiState.totalReadingMinutes * 60), "Total Time"),
                        StatItem(uiState.notes.size.toString(), "Notes")
                    ),
                    modifier = Modifier.padding(top = 16.dp)
                )

                // Action buttons
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    if (userBook.status == ReadingStatus.READING) {
                        Button(
                            onClick = { onStartReading(userBook.id) },
                            modifier = Modifier.weight(1f),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = QuietlyColors.Primary
                            )
                        ) {
                            Icon(Icons.Default.PlayArrow, null)
                            Spacer(Modifier.width(8.dp))
                            Text("Start Reading")
                        }
                    }

                    Button(
                        onClick = { onAddNote(userBook.id) },
                        modifier = Modifier.weight(1f),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = QuietlyColors.Accent
                        )
                    ) {
                        Text("Add Note")
                    }
                }

                // Status change buttons
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 16.dp),
                    colors = CardDefaults.cardColors(containerColor = QuietlyColors.Card)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Change Status", style = QuietlyTypography.titleMedium)

                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 12.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            ReadingStatus.entries.forEach { status ->
                                val isSelected = userBook.status == status
                                Button(
                                    onClick = { viewModel.updateStatus(status) },
                                    modifier = Modifier.weight(1f),
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = if (isSelected) QuietlyColors.Primary else QuietlyColors.SurfaceVariant,
                                        contentColor = if (isSelected) QuietlyColors.TextOnPrimary else QuietlyColors.TextPrimary
                                    ),
                                    shape = RoundedCornerShape(8.dp)
                                ) {
                                    Text(
                                        when (status) {
                                            ReadingStatus.WANT_TO_READ -> "Want"
                                            ReadingStatus.READING -> "Reading"
                                            ReadingStatus.COMPLETED -> "Done"
                                        },
                                        style = QuietlyTypography.labelSmall
                                    )
                                }
                            }
                        }
                    }
                }

                // Notes section
                if (uiState.notes.isNotEmpty()) {
                    Text(
                        "Notes",
                        style = QuietlyTypography.titleMedium,
                        modifier = Modifier.padding(top = 24.dp, bottom = 12.dp)
                    )
                    uiState.notes.forEach { note ->
                        NoteCard(
                            note = note,
                            onClick = { /* Navigate to note detail */ },
                            modifier = Modifier.padding(bottom = 8.dp)
                        )
                    }
                }

                // Description
                if (!book.description.isNullOrEmpty()) {
                    Text(
                        "Description",
                        style = QuietlyTypography.titleMedium,
                        modifier = Modifier.padding(top = 24.dp, bottom = 8.dp)
                    )
                    Text(
                        text = book.description,
                        style = QuietlyTypography.bodyMedium
                    )
                }

                Spacer(modifier = Modifier.height(32.dp))
            }
        }
    }
}
