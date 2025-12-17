package com.quietly.app.ui.screens.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.TabRowDefaults
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.quietly.app.data.model.Book
import com.quietly.app.data.model.ReadingStatus
import com.quietly.app.data.remote.OpenLibraryApi
import com.quietly.app.data.remote.OpenLibraryDoc
import com.quietly.app.ui.components.LoadingIndicator
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles
import com.quietly.app.ui.theme.QuietlyTypography

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddBookSheet(
    onDismiss: () -> Unit,
    onBookAdded: () -> Unit,
    viewModel: AddBookViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    var selectedTab by remember { mutableIntStateOf(0) }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = QuietlyColors.Background
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 32.dp)
        ) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "Add Book",
                    style = QuietlyTypography.headlineSmall
                )
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Close")
                }
            }

            // Tabs
            val tabs = listOf("Search", "ISBN", "Manual")
            TabRow(
                selectedTabIndex = selectedTab,
                containerColor = QuietlyColors.Background,
                indicator = { tabPositions ->
                    TabRowDefaults.SecondaryIndicator(
                        modifier = Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                        color = QuietlyColors.Primary
                    )
                }
            ) {
                tabs.forEachIndexed { index, title ->
                    Tab(
                        selected = selectedTab == index,
                        onClick = { selectedTab = index },
                        text = { Text(title) },
                        selectedContentColor = QuietlyColors.Primary,
                        unselectedContentColor = QuietlyColors.TextSecondary
                    )
                }
            }

            // Tab content
            when (selectedTab) {
                0 -> SearchTab(
                    viewModel = viewModel,
                    onBookAdded = onBookAdded
                )
                1 -> ISBNTab(
                    viewModel = viewModel,
                    onBookAdded = onBookAdded
                )
                2 -> ManualTab(
                    viewModel = viewModel,
                    onBookAdded = onBookAdded
                )
            }
        }
    }
}

@Composable
private fun SearchTab(
    viewModel: AddBookViewModel,
    onBookAdded: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        OutlinedTextField(
            value = uiState.searchQuery,
            onValueChange = viewModel::updateSearchQuery,
            label = { Text("Search books") },
            leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
            singleLine = true,
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
            keyboardActions = KeyboardActions(onSearch = { viewModel.searchBooks() }),
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = QuietlyColors.Primary,
                focusedLabelColor = QuietlyColors.Primary
            )
        )

        Button(
            onClick = { viewModel.searchBooks() },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp),
            colors = ButtonDefaults.buttonColors(containerColor = QuietlyColors.Primary),
            enabled = uiState.searchQuery.isNotBlank() && !uiState.isSearching
        ) {
            Text("Search")
        }

        Spacer(modifier = Modifier.height(16.dp))

        if (uiState.isSearching) {
            LoadingIndicator(modifier = Modifier.height(200.dp))
        } else {
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.height(300.dp)
            ) {
                items(uiState.searchResults) { doc ->
                    SearchResultItem(
                        doc = doc,
                        onClick = {
                            viewModel.selectSearchResult(doc)
                            viewModel.addSelectedBook(ReadingStatus.WANT_TO_READ)
                            onBookAdded()
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun SearchResultItem(
    doc: OpenLibraryDoc,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(containerColor = QuietlyColors.Card)
    ) {
        Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Cover
            Box(
                modifier = Modifier
                    .size(60.dp, 90.dp)
                    .clip(RoundedCornerShape(4.dp))
                    .background(QuietlyColors.SurfaceVariant)
            ) {
                val coverUrl = OpenLibraryApi.getCoverUrl(doc.cover_i, "S")
                if (coverUrl != null) {
                    AsyncImage(
                        model = coverUrl,
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

            Spacer(modifier = Modifier.width(12.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = doc.title ?: "Unknown Title",
                    style = QuietlyTextStyles.BookTitle,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = doc.author_name?.firstOrNull() ?: "Unknown Author",
                    style = QuietlyTextStyles.BookAuthor,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                if (doc.first_publish_year != null) {
                    Text(
                        text = doc.first_publish_year.toString(),
                        style = QuietlyTextStyles.StatLabel
                    )
                }
            }
        }
    }
}

@Composable
private fun ISBNTab(
    viewModel: AddBookViewModel,
    onBookAdded: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        OutlinedTextField(
            value = uiState.isbn,
            onValueChange = viewModel::updateISBN,
            label = { Text("ISBN") },
            placeholder = { Text("Enter ISBN-10 or ISBN-13") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = QuietlyColors.Primary,
                focusedLabelColor = QuietlyColors.Primary
            )
        )

        Button(
            onClick = {
                viewModel.lookupISBN()
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 16.dp),
            colors = ButtonDefaults.buttonColors(containerColor = QuietlyColors.Primary),
            enabled = uiState.isbn.isNotBlank() && !uiState.isSearching
        ) {
            Text("Look Up")
        }

        if (uiState.isbnBook != null) {
            Spacer(modifier = Modifier.height(16.dp))
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = QuietlyColors.Card)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = uiState.isbnBook!!.title,
                        style = QuietlyTextStyles.BookTitle
                    )
                    Text(
                        text = uiState.isbnBook!!.author,
                        style = QuietlyTextStyles.BookAuthor
                    )

                    Button(
                        onClick = {
                            viewModel.addISBNBook(ReadingStatus.WANT_TO_READ)
                            onBookAdded()
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 16.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = QuietlyColors.Accent)
                    ) {
                        Text("Add to Library")
                    }
                }
            }
        }

        if (uiState.error != null) {
            Text(
                text = uiState.error!!,
                style = QuietlyTypography.bodySmall.copy(color = QuietlyColors.Error),
                modifier = Modifier.padding(top = 8.dp)
            )
        }
    }
}

@Composable
private fun ManualTab(
    viewModel: AddBookViewModel,
    onBookAdded: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        OutlinedTextField(
            value = uiState.manualTitle,
            onValueChange = viewModel::updateManualTitle,
            label = { Text("Title *") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = QuietlyColors.Primary,
                focusedLabelColor = QuietlyColors.Primary
            )
        )

        Spacer(modifier = Modifier.height(12.dp))

        OutlinedTextField(
            value = uiState.manualAuthor,
            onValueChange = viewModel::updateManualAuthor,
            label = { Text("Author *") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = QuietlyColors.Primary,
                focusedLabelColor = QuietlyColors.Primary
            )
        )

        Spacer(modifier = Modifier.height(12.dp))

        OutlinedTextField(
            value = uiState.manualPageCount,
            onValueChange = viewModel::updateManualPageCount,
            label = { Text("Page Count") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = QuietlyColors.Primary,
                focusedLabelColor = QuietlyColors.Primary
            )
        )

        Button(
            onClick = {
                viewModel.addManualBook(ReadingStatus.WANT_TO_READ)
                onBookAdded()
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 24.dp),
            colors = ButtonDefaults.buttonColors(containerColor = QuietlyColors.Primary),
            enabled = uiState.manualTitle.isNotBlank() && uiState.manualAuthor.isNotBlank()
        ) {
            Text("Add Book")
        }
    }
}
