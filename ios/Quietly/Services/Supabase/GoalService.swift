import Foundation
import Supabase

final class GoalService {
    private let client = SupabaseManager.shared.client
    private let sessionService = SessionService()
    private let bookService = BookService()

    // MARK: - Fetch Goals
    func fetchGoals() async throws -> [ReadingGoal] {
        let userId = try SupabaseManager.shared.requireUserId()

        let response: [ReadingGoal] = try await client.database
            .from(SupabaseTable.readingGoals.rawValue)
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return response
    }

    // MARK: - Add or Update Goal
    func upsertGoal(goalType: GoalType, targetValue: Int) async throws -> ReadingGoal {
        let userId = try SupabaseManager.shared.requireUserId()

        let insert = ReadingGoalInsert(
            userId: userId,
            goalType: goalType,
            targetValue: targetValue
        )

        let response: [ReadingGoal] = try await client.database
            .from(SupabaseTable.readingGoals.rawValue)
            .upsert(insert, onConflict: "user_id,goal_type")
            .select()
            .execute()
            .value

        guard let goal = response.first else {
            throw SupabaseError.databaseError("Failed to create goal")
        }

        return goal
    }

    // MARK: - Update Goal Target
    func updateGoalTarget(goalId: UUID, targetValue: Int) async throws {
        try await client.database
            .from(SupabaseTable.readingGoals.rawValue)
            .update(["target_value": targetValue])
            .eq("id", value: goalId.uuidString)
            .execute()
    }

    // MARK: - Delete Goal
    func deleteGoal(goalId: UUID) async throws {
        try await client.database
            .from(SupabaseTable.readingGoals.rawValue)
            .delete()
            .eq("id", value: goalId.uuidString)
            .execute()
    }

    // MARK: - Calculate Goal Progress
    func calculateProgress(for goal: ReadingGoal) async throws -> GoalProgress {
        let currentValue: Int

        switch goal.goalType {
        case .dailyMinutes:
            let startOfDay = Date().startOfDay
            currentValue = try await sessionService.getTotalReadingMinutes(since: startOfDay)

        case .weeklyMinutes:
            let startOfWeek = Date().startOfWeek
            currentValue = try await sessionService.getTotalReadingMinutes(since: startOfWeek)

        case .booksPerMonth:
            currentValue = try await countCompletedBooks(since: Date().startOfMonth)

        case .booksPerYear:
            currentValue = try await countCompletedBooks(since: Date().startOfYear)
        }

        return GoalProgress(
            id: goal.id,
            goal: goal,
            currentValue: currentValue,
            targetValue: goal.targetValue
        )
    }

    // MARK: - Calculate All Goals Progress
    func calculateAllProgress(for goals: [ReadingGoal]) async throws -> [GoalProgress] {
        var progressList: [GoalProgress] = []

        for goal in goals {
            let progress = try await calculateProgress(for: goal)
            progressList.append(progress)
        }

        return progressList
    }

    // MARK: - Count Completed Books
    private func countCompletedBooks(since date: Date) async throws -> Int {
        let books = try await bookService.fetchUserBooks()

        return books.filter { userBook in
            guard userBook.status == .completed,
                  let completedAt = userBook.completedAt else { return false }
            return completedAt >= date
        }.count
    }

    // MARK: - Check if Goal Type Exists
    func hasGoal(ofType type: GoalType) async throws -> Bool {
        let goals = try await fetchGoals()
        return goals.contains { $0.goalType == type }
    }

    // MARK: - Get Available Goal Types
    func getAvailableGoalTypes() async throws -> [GoalType] {
        let existingGoals = try await fetchGoals()
        let existingTypes = Set(existingGoals.map { $0.goalType })
        return GoalType.allCases.filter { !existingTypes.contains($0) }
    }
}
