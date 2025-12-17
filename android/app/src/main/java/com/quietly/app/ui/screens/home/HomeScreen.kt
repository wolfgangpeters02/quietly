package com.quietly.app.ui.screens.home

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Book
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.ScrollableTabRow
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRowDefaults
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.quietly.app.ui.components.BookCard
import com.quietly.app.ui.components.EmptyStates
import com.quietly.app.ui.components.LoadingIndicator
import com.quietly.app.ui.components.StatItem
import com.quietly.app.ui.components.StatsCard
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTypography

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onBookClick: (String) -> Unit,
    onAddBook: () -> Unit,
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadData()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Quietly",
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
                onClick = onAddBook,
                containerColor = QuietlyColors.Primary,
                contentColor = QuietlyColors.TextOnPrimary
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add Book")
            }
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
            ) {
                // Stats Card
                StatsCard(
                    stats = listOf(
                        StatItem(uiState.stats.booksRead.toString(), "Books Read"),
                        StatItem("${uiState.stats.minutesToday}m", "Today"),
                        StatItem(uiState.stats.currentStreak.toString(), "Day Streak"),
                        StatItem(uiState.stats.totalBooks.toString(), "Library")
                    ),
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                )

                // Tab Row
                val tabs = listOf("All", "Reading", "Want to Read", "Completed")
                ScrollableTabRow(
                    selectedTabIndex = uiState.selectedTab,
                    containerColor = QuietlyColors.Background,
                    contentColor = QuietlyColors.Primary,
                    edgePadding = 16.dp,
                    indicator = { tabPositions ->
                        TabRowDefaults.SecondaryIndicator(
                            modifier = Modifier.tabIndicatorOffset(tabPositions[uiState.selectedTab]),
                            color = QuietlyColors.Primary
                        )
                    }
                ) {
                    tabs.forEachIndexed { index, title ->
                        Tab(
                            selected = uiState.selectedTab == index,
                            onClick = { viewModel.selectTab(index) },
                            text = {
                                Text(
                                    title,
                                    style = QuietlyTypography.labelLarge
                                )
                            },
                            selectedContentColor = QuietlyColors.Primary,
                            unselectedContentColor = QuietlyColors.TextSecondary
                        )
                    }
                }

                // Book Grid
                val filteredBooks = viewModel.getFilteredBooks()

                if (filteredBooks.isEmpty()) {
                    EmptyStates.NoBooks(onAddBook = onAddBook)
                } else {
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(2),
                        contentPadding = PaddingValues(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(filteredBooks, key = { it.id }) { userBook ->
                            BookCard(
                                userBook = userBook,
                                onClick = { onBookClick(userBook.id) }
                            )
                        }
                    }
                }
            }
        }
    }
}
