package com.quietly.app.ui.screens.goals

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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.quietly.app.data.model.GoalType
import com.quietly.app.ui.components.EmptyStates
import com.quietly.app.ui.components.GoalCard
import com.quietly.app.ui.components.LoadingIndicator
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTypography

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GoalsScreen(
    viewModel: GoalsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Reading Goals",
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
                Icon(Icons.Default.Add, contentDescription = "Add Goal")
            }
        },
        containerColor = QuietlyColors.Background
    ) { padding ->
        if (uiState.isLoading) {
            LoadingIndicator()
        } else if (uiState.goals.isEmpty()) {
            EmptyStates.NoGoals(onAddGoal = { viewModel.showAddDialog() })
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(uiState.goals, key = { it.id }) { goal ->
                    GoalCard(
                        goal = goal,
                        onClick = { /* Navigate to goal detail */ }
                    )
                }
            }
        }

        // Add Goal Dialog
        if (uiState.showAddDialog) {
            AddGoalDialog(
                selectedType = uiState.selectedGoalType,
                targetValue = uiState.targetValue,
                onTypeChange = viewModel::updateGoalType,
                onTargetChange = viewModel::updateTargetValue,
                onDismiss = viewModel::hideAddDialog,
                onConfirm = viewModel::createGoal,
                error = uiState.error
            )
        }
    }
}

@Composable
fun AddGoalDialog(
    selectedType: GoalType,
    targetValue: String,
    onTypeChange: (GoalType) -> Unit,
    onTargetChange: (String) -> Unit,
    onDismiss: () -> Unit,
    onConfirm: () -> Unit,
    error: String?
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Create Reading Goal") },
        text = {
            Column {
                Text(
                    "Goal Type",
                    style = QuietlyTypography.titleSmall,
                    modifier = Modifier.padding(bottom = 8.dp)
                )

                GoalType.entries.forEach { type ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .selectable(
                                selected = selectedType == type,
                                onClick = { onTypeChange(type) },
                                role = Role.RadioButton
                            )
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedType == type,
                            onClick = null,
                            colors = RadioButtonDefaults.colors(
                                selectedColor = QuietlyColors.Primary
                            )
                        )
                        Text(
                            text = getGoalTypeLabel(type),
                            style = QuietlyTypography.bodyMedium,
                            modifier = Modifier.padding(start = 8.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                OutlinedTextField(
                    value = targetValue,
                    onValueChange = onTargetChange,
                    label = { Text(getTargetLabel(selectedType)) },
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
                Text("Create")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

private fun getGoalTypeLabel(type: GoalType): String {
    return when (type) {
        GoalType.DAILY_MINUTES -> "Daily Reading Minutes"
        GoalType.WEEKLY_MINUTES -> "Weekly Reading Minutes"
        GoalType.BOOKS_PER_MONTH -> "Books per Month"
        GoalType.BOOKS_PER_YEAR -> "Books per Year"
    }
}

private fun getTargetLabel(type: GoalType): String {
    return when (type) {
        GoalType.DAILY_MINUTES, GoalType.WEEKLY_MINUTES -> "Target Minutes"
        GoalType.BOOKS_PER_MONTH, GoalType.BOOKS_PER_YEAR -> "Target Books"
    }
}
