import Foundation
import SwiftUI

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
    func loadData() async {
        isLoading = true

        do {
            async let goalsTask = goalService.fetchGoals()
            async let typesTask = goalService.getAvailableGoalTypes()

            let (fetchedGoals, fetchedTypes) = try await (goalsTask, typesTask)

            goals = fetchedGoals
            availableTypes = fetchedTypes

            if let firstAvailable = fetchedTypes.first {
                newGoalType = firstAvailable
                newTargetValue = suggestedTarget
            }

            // Calculate progress for all goals
            progressList = try await goalService.calculateAllProgress(for: fetchedGoals)

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }

    // MARK: - Goal Actions
    func addGoal() async {
        guard newTargetValue > 0 else {
            error = "Target must be greater than 0"
            return
        }

        isLoading = true

        do {
            let goal = try await goalService.upsertGoal(
                goalType: newGoalType,
                targetValue: newTargetValue
            )

            goals.append(goal)
            availableTypes.removeAll { $0 == newGoalType }

            // Calculate progress for new goal
            let progress = try await goalService.calculateProgress(for: goal)
            progressList.append(progress)

            // Reset form
            if let nextType = availableTypes.first {
                newGoalType = nextType
                newTargetValue = suggestedTarget
            }

            showAddGoal = false

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func deleteGoal(_ goal: ReadingGoal) async {
        do {
            try await goalService.deleteGoal(goalId: goal.id)
            goals.removeAll { $0.id == goal.id }
            progressList.removeAll { $0.id == goal.id }
            availableTypes.append(goal.goalType)
            availableTypes.sort { $0.rawValue < $1.rawValue }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateGoalTarget(_ goal: ReadingGoal, newTarget: Int) async {
        guard newTarget > 0 else { return }

        do {
            try await goalService.updateGoalTarget(goalId: goal.id, targetValue: newTarget)

            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index].targetValue = newTarget
            }

            // Recalculate progress
            if let index = progressList.firstIndex(where: { $0.id == goal.id }) {
                let updatedGoal = goals.first { $0.id == goal.id }!
                let newProgress = try await goalService.calculateProgress(for: updatedGoal)
                progressList[index] = newProgress
            }

        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Error Handling
    func clearError() {
        error = nil
    }
}
