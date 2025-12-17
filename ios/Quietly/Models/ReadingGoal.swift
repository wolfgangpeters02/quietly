import Foundation
import SwiftData

@Model
final class ReadingGoal {
    @Attribute(.unique) var id: UUID
    var goalType: GoalType
    var targetValue: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        goalType: GoalType,
        targetValue: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.goalType = goalType
        self.targetValue = targetValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var displayTarget: String {
        "\(targetValue) \(goalType.unit)"
    }
}

// MARK: - Goal Progress
struct GoalProgress: Identifiable {
    let id: UUID
    let goal: ReadingGoal
    let currentValue: Int
    let targetValue: Int

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    var isComplete: Bool {
        currentValue >= targetValue
    }

    var progressText: String {
        "\(currentValue) / \(targetValue) \(goal.goalType.unit)"
    }
}
