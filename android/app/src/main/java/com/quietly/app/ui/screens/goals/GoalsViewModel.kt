package com.quietly.app.ui.screens.goals

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.quietly.app.data.model.GoalType
import com.quietly.app.data.model.ReadingGoal
import com.quietly.app.data.repository.GoalRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

data class GoalsUiState(
    val isLoading: Boolean = true,
    val goals: List<ReadingGoal> = emptyList(),
    val showAddDialog: Boolean = false,
    val selectedGoalType: GoalType = GoalType.DAILY_MINUTES,
    val targetValue: String = "",
    val error: String? = null
)

@HiltViewModel
class GoalsViewModel @Inject constructor(
    private val goalRepository: GoalRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(GoalsUiState())
    val uiState: StateFlow<GoalsUiState> = _uiState.asStateFlow()

    init {
        loadGoals()
    }

    fun loadGoals() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val goals = goalRepository.getActiveGoals().first()
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    goals = goals
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Failed to load goals"
                )
            }
        }
    }

    fun showAddDialog() {
        _uiState.value = _uiState.value.copy(
            showAddDialog = true,
            selectedGoalType = GoalType.DAILY_MINUTES,
            targetValue = ""
        )
    }

    fun hideAddDialog() {
        _uiState.value = _uiState.value.copy(showAddDialog = false)
    }

    fun updateGoalType(type: GoalType) {
        _uiState.value = _uiState.value.copy(selectedGoalType = type)
    }

    fun updateTargetValue(value: String) {
        _uiState.value = _uiState.value.copy(targetValue = value)
    }

    fun createGoal() {
        val targetValue = _uiState.value.targetValue.toIntOrNull()
        if (targetValue == null || targetValue <= 0) {
            _uiState.value = _uiState.value.copy(error = "Please enter a valid target")
            return
        }

        viewModelScope.launch {
            val result = goalRepository.createGoal(
                goalType = _uiState.value.selectedGoalType,
                targetValue = targetValue
            )
            result.fold(
                onSuccess = {
                    _uiState.value = _uiState.value.copy(showAddDialog = false)
                    loadGoals()
                },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to create goal"
                    )
                }
            )
        }
    }

    fun deleteGoal(goalId: String) {
        viewModelScope.launch {
            val result = goalRepository.deleteGoal(goalId)
            result.fold(
                onSuccess = { loadGoals() },
                onFailure = { e ->
                    _uiState.value = _uiState.value.copy(
                        error = e.message ?: "Failed to delete goal"
                    )
                }
            )
        }
    }
}
