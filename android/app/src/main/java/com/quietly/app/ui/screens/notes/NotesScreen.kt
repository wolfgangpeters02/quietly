package com.quietly.app.ui.screens.notes

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.selection.selectable
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
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
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.quietly.app.data.model.NoteType
import com.quietly.app.ui.components.EmptyStates
import com.quietly.app.ui.components.LoadingIndicator
import com.quietly.app.ui.components.NoteCard
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTypography

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotesScreen(
    viewModel: NotesViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Notes",
                        style = QuietlyTypography.headlineMedium.copy(color = QuietlyColors.Primary)
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = QuietlyColors.Background
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { viewModel.showAddDialog() },
                containerColor = QuietlyColors.Primary,
                contentColor = QuietlyColors.TextOnPrimary
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add Note")
            }
        },
        containerColor = QuietlyColors.Background
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // Search bar
            OutlinedTextField(
                value = uiState.searchQuery,
                onValueChange = viewModel::updateSearchQuery,
                placeholder = { Text("Search notes...") },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
                singleLine = true,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = QuietlyColors.Primary,
                    focusedLabelColor = QuietlyColors.Primary
                )
            )

            // Filter chips
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                NoteFilter.entries.forEach { filter ->
                    FilterChip(
                        selected = uiState.selectedFilter == filter,
                        onClick = { viewModel.updateFilter(filter) },
                        label = {
                            Text(
                                when (filter) {
                                    NoteFilter.ALL -> "All"
                                    NoteFilter.NOTES -> "Notes"
                                    NoteFilter.QUOTES -> "Quotes"
                                }
                            )
                        },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = QuietlyColors.Primary,
                            selectedLabelColor = QuietlyColors.TextOnPrimary
                        )
                    )
                }
            }

            if (uiState.isLoading) {
                LoadingIndicator()
            } else if (uiState.filteredNotes.isEmpty()) {
                EmptyStates.NoNotes(onAddNote = { viewModel.showAddDialog() })
            } else {
                // Notes grouped by book
                val groupedNotes = viewModel.getNotesGroupedByBook()

                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    groupedNotes.forEach { (bookTitle, notes) ->
                        item {
                            Text(
                                text = bookTitle ?: "Unknown Book",
                                style = QuietlyTypography.titleMedium,
                                modifier = Modifier.padding(top = 8.dp, bottom = 4.dp)
                            )
                        }
                        items(notes, key = { it.id }) { note ->
                            NoteCard(
                                note = note,
                                onClick = { /* Navigate to note detail */ }
                            )
                        }
                    }
                }
            }
        }

        // Add Note Dialog
        if (uiState.showAddDialog) {
            AddNoteDialog(
                userBooks = uiState.userBooks,
                selectedBookId = uiState.selectedBookId,
                noteContent = uiState.noteContent,
                noteType = uiState.noteType,
                pageNumber = uiState.pageNumber,
                onBookChange = viewModel::updateSelectedBook,
                onContentChange = viewModel::updateNoteContent,
                onTypeChange = viewModel::updateNoteType,
                onPageChange = viewModel::updatePageNumber,
                onDismiss = viewModel::hideAddDialog,
                onConfirm = viewModel::createNote,
                error = uiState.error
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddNoteDialog(
    userBooks: List<com.quietly.app.data.model.UserBook>,
    selectedBookId: String?,
    noteContent: String,
    noteType: NoteType,
    pageNumber: String,
    onBookChange: (String) -> Unit,
    onContentChange: (String) -> Unit,
    onTypeChange: (NoteType) -> Unit,
    onPageChange: (String) -> Unit,
    onDismiss: () -> Unit,
    onConfirm: () -> Unit,
    error: String?
) {
    var expanded by remember { mutableStateOf(false) }
    val selectedBook = userBooks.find { it.id == selectedBookId }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Note") },
        text = {
            Column {
                // Book selector
                ExposedDropdownMenuBox(
                    expanded = expanded,
                    onExpandedChange = { expanded = it }
                ) {
                    OutlinedTextField(
                        value = selectedBook?.book?.title ?: "Select a book",
                        onValueChange = {},
                        readOnly = true,
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .menuAnchor(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = QuietlyColors.Primary
                        )
                    )
                    ExposedDropdownMenu(
                        expanded = expanded,
                        onDismissRequest = { expanded = false }
                    ) {
                        userBooks.forEach { userBook ->
                            DropdownMenuItem(
                                text = { Text(userBook.book?.title ?: "Unknown") },
                                onClick = {
                                    onBookChange(userBook.id)
                                    expanded = false
                                }
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Note type
                Row(
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    NoteType.entries.forEach { type ->
                        Row(
                            modifier = Modifier
                                .selectable(
                                    selected = noteType == type,
                                    onClick = { onTypeChange(type) },
                                    role = Role.RadioButton
                                ),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = noteType == type,
                                onClick = null,
                                colors = RadioButtonDefaults.colors(
                                    selectedColor = QuietlyColors.Primary
                                )
                            )
                            Text(
                                if (type == NoteType.NOTE) "Note" else "Quote",
                                modifier = Modifier.padding(start = 4.dp)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Content
                OutlinedTextField(
                    value = noteContent,
                    onValueChange = onContentChange,
                    label = { Text(if (noteType == NoteType.QUOTE) "Quote" else "Note") },
                    minLines = 3,
                    maxLines = 5,
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = QuietlyColors.Primary,
                        focusedLabelColor = QuietlyColors.Primary
                    )
                )

                Spacer(modifier = Modifier.height(12.dp))

                // Page number
                OutlinedTextField(
                    value = pageNumber,
                    onValueChange = onPageChange,
                    label = { Text("Page Number (optional)") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = QuietlyColors.Primary,
                        focusedLabelColor = QuietlyColors.Primary
                    )
                )

                if (error != null) {
                    Text(
                        text = error,
                        style = QuietlyTypography.bodySmall.copy(color = QuietlyColors.Error),
                        modifier = Modifier.padding(top = 8.dp)
                    )
                }
            }
        },
        confirmButton = {
            Button(
                onClick = onConfirm,
                colors = ButtonDefaults.buttonColors(containerColor = QuietlyColors.Primary)
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
