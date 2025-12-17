package com.quietly.app.ui.screens.session

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Book
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.quietly.app.ui.components.LoadingIndicator
import com.quietly.app.ui.components.ReadingTimer
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles
import com.quietly.app.ui.theme.QuietlyTypography

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReadingSessionScreen(
    onBack: () -> Unit,
    onSessionEnded: () -> Unit,
    viewModel: ReadingSessionViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.isSessionEnded) {
        if (uiState.isSessionEnded) {
            onSessionEnded()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Reading Session") },
                navigationIcon = {
                    IconButton(onClick = {
                        if (uiState.session != null) {
                            viewModel.showEndDialog()
                        } else {
                            onBack()
                        }
                    }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
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
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Book info card
                val userBook = uiState.userBook
                val book = userBook?.book

                if (book != null) {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(containerColor = QuietlyColors.Card),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            // Cover
                            Box(
                                modifier = Modifier
                                    .size(60.dp, 90.dp)
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(QuietlyColors.SurfaceVariant)
                            ) {
                                if (!book.coverUrl.isNullOrEmpty()) {
                                    AsyncImage(
                                        model = book.coverUrl,
                                        contentDescription = null,
                                        modifier = Modifier.fillMaxSize(),
                                        contentScale = ContentScale.Crop
                                    )
                                } else {
                                    Icon(
                                        Icons.Default.Book,
                                        contentDescription = null,
                                        modifier = Modifier
                                            .size(24.dp)
                                            .align(Alignment.Center),
                                        tint = QuietlyColors.TextTertiary
                                    )
                                }
                            }

                            Spacer(modifier = Modifier.width(16.dp))

                            Column {
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
                                    overflow = TextOverflow.Ellipsis
                                )
                                if (userBook.currentPage > 0 && book.pageCount != null) {
                                    Text(
                                        text = "Page ${userBook.currentPage} of ${book.pageCount}",
                                        style = QuietlyTextStyles.StatLabel,
                                        modifier = Modifier.padding(top = 4.dp)
                                    )
                                }
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.weight(1f))

                // Timer
                val session = uiState.session
                if (session != null) {
                    ReadingTimer(
                        startTimeMillis = viewModel.getStartTimeMillis(),
                        totalPausedSeconds = session.totalPausedSeconds,
                        isPaused = uiState.isPaused,
                        pausedAtMillis = viewModel.getPausedAtMillis(),
                        onPauseResume = { viewModel.togglePause() },
                        onStop = { viewModel.showEndDialog() }
                    )
                }

                Spacer(modifier = Modifier.weight(1f))
            }

            // End session dialog
            if (uiState.showEndDialog) {
                EndSessionDialog(
                    endPage = uiState.endPage,
                    sessionNotes = uiState.sessionNotes,
                    onEndPageChange = viewModel::updateEndPage,
                    onNotesChange = viewModel::updateSessionNotes,
                    onDismiss = viewModel::hideEndDialog,
                    onConfirm = viewModel::endSession
                )
            }
        }
    }
}

@Composable
fun EndSessionDialog(
    endPage: String,
    sessionNotes: String,
    onEndPageChange: (String) -> Unit,
    onNotesChange: (String) -> Unit,
    onDismiss: () -> Unit,
    onConfirm: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("End Reading Session") },
        text = {
            Column {
                OutlinedTextField(
                    value = endPage,
                    onValueChange = onEndPageChange,
                    label = { Text("Current Page") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = QuietlyColors.Primary,
                        focusedLabelColor = QuietlyColors.Primary
                    )
                )

                Spacer(modifier = Modifier.height(16.dp))

                OutlinedTextField(
                    value = sessionNotes,
                    onValueChange = onNotesChange,
                    label = { Text("Session Notes (optional)") },
                    minLines = 3,
                    maxLines = 5,
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = QuietlyColors.Primary,
                        focusedLabelColor = QuietlyColors.Primary
                    )
                )
            }
        },
        confirmButton = {
            Button(
                onClick = onConfirm,
                colors = ButtonDefaults.buttonColors(containerColor = QuietlyColors.Primary)
            ) {
                Text("End Session")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
