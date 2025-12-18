import Foundation
import SwiftData

final class GoalService {
    private let sessionService = SessionService()
    private let bookService = BookService()

    // MARK: - Fetch Goals
    func fetchGoals(context: ModelContext) -> [ReadingGoal] {
        let descriptor = FetchDescriptor<ReadingGoal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch goals: \(error)")
            return []
        }
    }

    // MARK: - Fetch Goal by Type
    func fetchGoal(type: GoalType, context: ModelContext) -> ReadingGoal? {
        let descriptor = FetchDescriptor<ReadingGoal>(
            predicate: #Predicate { $0.goalType == type }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Failed to fetch goal: \(error)")
            return nil
        }
    }

    // MARK: - Add or Update Goal
    func upsertGoal(goalType: GoalType, targetValue: Int, context: ModelContext) -> ReadingGoal {
        // Check if goal exists
        if let existingGoal = fetchGoal(type: goalType, context: context) {
            existingGoal.targetValue = targetValue
            existingGoal.updatedAt = Date()
            return existingGoal
        }

        // Create new goal
        let goal = ReadingGoal(
            goalType: goalType,
            targetValue: targetValue
        )
        context.insert(goal)
        return goal
    }

    // MARK: - Update Goal Target
    func updateGoalTarget(_ goal: ReadingGoal, targetValue: Int, context: ModelContext) {
        goal.targetValue = targetValue
        goal.updatedAt = Date()
    }

    // MARK: - Delete Goal
    func deleteGoal(_ goal: ReadingGoal, context: ModelContext) {
        context.delete(goal)
    }

    // MARK: - Calculate Goal Progress
    func calculateProgress(for goal: ReadingGoal, context: ModelContext) -> GoalProgress {
        let currentValue: Int

        switch goal.goalType {
        case .dailyMinutes:
            let startOfDay = Date().startOfDay
            currentValue = sessionService.getTotalReadingMinutes(since: startOfDay, context: context)

        case .weeklyMinutes:
            let startOfWeek = Date().startOfWeek
            currentValue = sessionService.getTotalReadingMinutes(since: startOfWeek, context: context)

        case .booksPerMonth:
            currentValue = countCompletedBooks(since: Date().startOfMonth, context: context)

        case .booksPerYear:
            currentValue = countCompletedBooks(since: Date().startOfYear, context: context)
        }

        return GoalProgress(
            id: goal.id,
            goal: goal,
            currentValue: currentValue,
            targetValue: goal.targetValue
        )
    }

    // MARK: - Calculate All Goals Progress
    func calculateAllProgress(for goals: [ReadingGoal], context: ModelContext) -> [GoalProgress] {
        goals.map { calculateProgress(for: $0, context: context) }
    }

    // MARK: - Count Completed Books
    private func countCompletedBooks(since date: Date, context: ModelContext) -> Int {
        let books = bookService.fetchUserBooks(context: context)

        return books.filter { userBook in
            guard userBook.status == .completed,
                  let completedAt = userBook.completedAt else { return false }
            return completedAt >= date
        }.count
    }

    // MARK: - Check if Goal Type Exists
    func hasGoal(ofType type: GoalType, context: ModelContext) -> Bool {
        fetchGoal(type: type, context: context) != nil
    }

    // MARK: - Get Available Goal Types
    func getAvailableGoalTypes(context: ModelContext) -> [GoalType] {
        let existingGoals = fetchGoals(context: context)
        let existingTypes = Set(existingGoals.map { $0.goalType })
        return GoalType.allCases.filter { !existingTypes.contains($0) }
    }
}
