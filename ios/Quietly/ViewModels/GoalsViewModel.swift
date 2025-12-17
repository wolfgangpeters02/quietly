import Foundation
import SwiftUI
import SwiftData

@MainActor
final class GoalsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var goals: [ReadingGoal] = []
    @Published var progressList: [GoalProgress] = []
    @Published var availableTypes: [GoalType] = []
    @Published var isLoading = false
    @Published var error: String?

    // New goal form
    @Published var newGoalType: GoalType = .dailyMinutes
    @Published var newTargetValue: Int = 30
    @Published var showAddGoal = false

    // MARK: - Dependencies
    private let goalService = GoalService()

    // MARK: - Computed Properties
    var hasGoals: Bool {
        !goals.isEmpty
    }

    var canAddMoreGoals: Bool {
        !availableTypes.isEmpty
    }

    var suggestedTarget: Int {
        switch newGoalType {
        case .dailyMinutes:
            return 30
        case .weeklyMinutes:
            return 150
        case .booksPerMonth:
            return 2
        case .booksPerYear:
            return 12
        }
    }

    // MARK: - Data Loading
    func loadData(context: ModelContext) {
        isLoading = true

        goals = goalService.fetchGoals(context: context)
        availableTypes = goalService.getAvailableGoalTypes(context: context)

        if let firstAvailable = availableTypes.first {
            newGoalType = firstAvailable
            newTargetValue = suggestedTarget
        }

        // Calculate progress for all goals
        progressList = goalService.calculateAllProgress(for: goals, context: context)

        isLoading = false
    }

    func refresh(context: ModelContext) {
        loadData(context: context)
    }

    // MARK: - Goal Actions
    func addGoal(context: ModelContext) {
        guard newTargetValue > 0 else {
            error = "Target must be greater than 0"
            return
        }

        isLoading = true

        let goal = goalService.upsertGoal(
            goalType: newGoalType,
            targetValue: newTargetValue,
            context: context
        )

        goals.append(goal)
        availableTypes.removeAll { $0 == newGoalType }

        // Calculate progress for new goal
        let progress = goalService.calculateProgress(for: goal, context: context)
        progressList.append(progress)

        // Reset form
        if let nextType = availableTypes.first {
            newGoalType = nextType
            newTargetValue = suggestedTarget
        }

        showAddGoal = false
        isLoading = false
        HapticService.shared.success()
    }

    func deleteGoal(_ goal: ReadingGoal, context: ModelContext) {
        goalService.deleteGoal(goal, context: context)
        goals.removeAll { $0.id == goal.id }
        progressList.removeAll { $0.id == goal.id }
        availableTypes.append(goal.goalType)
        availableTypes.sort { $0.rawValue < $1.rawValue }
        HapticService.shared.deleted()
    }

    func updateGoalTarget(_ goal: ReadingGoal, newTarget: Int, context: ModelContext) {
        guard newTarget > 0 else { return }

        goalService.updateGoalTarget(goal, targetValue: newTarget, context: context)

        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].targetValue = newTarget
        }

        // Recalculate progress
        if let index = progressList.firstIndex(where: { $0.id == goal.id }) {
            if let updatedGoal = goals.first(where: { $0.id == goal.id }) {
                let newProgress = goalService.calculateProgress(for: updatedGoal, context: context)
                progressList[index] = newProgress
            }
        }
    }

    // MARK: - Error Handling
    func clearError() {
        error = nil
    }
}
