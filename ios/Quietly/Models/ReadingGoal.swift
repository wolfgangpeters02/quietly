import Foundation

struct ReadingGoal: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let goalType: GoalType
    var targetValue: Int
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case goalType = "goal_type"
        case targetValue = "target_value"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var displayTarget: String {
        "\(targetValue) \(goalType.unit)"
    }
}

// MARK: - Insert Model
struct ReadingGoalInsert: Codable {
    let userId: UUID
    let goalType: GoalType
    let targetValue: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case goalType = "goal_type"
        case targetValue = "target_value"
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
