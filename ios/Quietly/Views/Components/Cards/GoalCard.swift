import SwiftUI

struct GoalCard: View {
    let progress: GoalProgress
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: progress.goal.goalType.iconName)
                        .font(.title3)
                        .foregroundColor(Color.quietly.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(progress.goal.goalType.displayName)
                            .font(.headline)
                            .foregroundColor(Color.quietly.textPrimary)

                        Text(progress.goal.goalType.periodDescription)
                            .font(.caption)
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                }

                Spacer()

                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundColor(Color.quietly.destructive)
                    }
                }
            }

            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(progress.progressText)
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    Spacer()

                    Text("\(progress.progressPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(progress.isComplete ? Color.quietly.success : Color.quietly.textPrimary)
                }

                ProgressView(value: progress.progress)
                    .tint(progress.isComplete ? Color.quietly.success : Color.quietly.accent)
            }

            // Completion badge
            if progress.isComplete {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.quietly.success)

                    Text("Goal achieved!")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.quietly.success)
                }
            }
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.quietly.shadow, radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        GoalCard(
            progress: GoalProgress(
                id: UUID(),
                goal: ReadingGoal(
                    id: UUID(),
                    userId: UUID(),
                    goalType: .dailyMinutes,
                    targetValue: 30,
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                currentValue: 15,
                targetValue: 30
            )
        ) {
            print("Delete")
        }

        GoalCard(
            progress: GoalProgress(
                id: UUID(),
                goal: ReadingGoal(
                    id: UUID(),
                    userId: UUID(),
                    goalType: .booksPerMonth,
                    targetValue: 4,
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                currentValue: 4,
                targetValue: 4
            )
        )
    }
    .padding()
    .background(Color.quietly.background)
}
