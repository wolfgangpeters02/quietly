import SwiftUI
import SwiftData
import TipKit

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GoalsViewModel()
    @State private var showNotificationPrompt = false
    @State private var hasCheckedNotifications = false

    // Tips
    private let setGoalTip = SetGoalTip()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Tip for new users
                    if viewModel.progressList.isEmpty {
                        TipView(setGoalTip)
                            .padding(.horizontal)
                    }

                    // Notification prompt (shown once after adding first goal)
                    if showNotificationPrompt {
                        notificationPromptCard
                            .padding(.horizontal)
                    }

                    // Empty state
                    if viewModel.progressList.isEmpty && !viewModel.isLoading {
                        emptyState
                    } else {
                        // Time-based goals (daily/weekly) - prominent display
                        let timeGoals = viewModel.progressList.filter {
                            $0.goal.goalType == .dailyMinutes || $0.goal.goalType == .weeklyMinutes
                        }
                        if !timeGoals.isEmpty {
                            goalsSection(title: "Reading Time", goals: timeGoals)
                        }

                        // Book count goals - compact display
                        let bookGoals = viewModel.progressList.filter {
                            $0.goal.goalType == .booksPerMonth || $0.goal.goalType == .booksPerYear
                        }
                        if !bookGoals.isEmpty {
                            bookGoalsSection(goals: bookGoals)
                        }
                    }

                    // Add goal button
                    if viewModel.canAddMoreGoals {
                        addGoalButton
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.quietly.background)
            .navigationTitle("Reading Goals")
            .refreshable {
                viewModel.refresh(context: modelContext)
            }
            .onAppear {
                viewModel.loadData(context: modelContext)
                checkNotificationStatus()
            }
            .overlay {
                if viewModel.isLoading && viewModel.progressList.isEmpty {
                    LoadingView(message: "Loading goals...")
                }
            }
            .sheet(isPresented: $viewModel.showAddGoal) {
                addGoalSheet
            }
        }
    }

    // MARK: - Notification Prompt Card
    private var notificationPromptCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge")
                    .font(.title2)
                    .foregroundColor(Color.quietly.accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Stay on track")
                        .font(.headline)
                        .foregroundColor(Color.quietly.textPrimary)

                    Text("Get daily reminders to meet your reading goals")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                }

                Spacer()
            }

            HStack(spacing: 12) {
                Button {
                    withAnimation {
                        showNotificationPrompt = false
                        UserDefaults.standard.set(true, forKey: "dismissedGoalNotificationPrompt")
                    }
                } label: {
                    Text("Not now")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }

                Button {
                    Task {
                        await enableNotifications()
                    }
                } label: {
                    Text("Enable")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.quietly.primaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.quietly.primary)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(16)
    }

    // MARK: - Goals Section (Time-based)
    private func goalsSection(title: String, goals: [GoalProgress]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)
                .padding(.horizontal)

            ForEach(goals) { progress in
                TimeGoalCard(progress: progress) {
                    viewModel.deleteGoal(progress.goal, context: modelContext)
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Book Goals Section (Compact)
    private func bookGoalsSection(goals: [GoalProgress]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Books")
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)
                .padding(.horizontal)

            HStack(spacing: 12) {
                ForEach(goals) { progress in
                    CompactGoalCard(progress: progress) {
                        viewModel.deleteGoal(progress.goal, context: modelContext)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 48))
                .foregroundColor(Color.quietly.textMuted)

            VStack(spacing: 8) {
                Text("No goals yet")
                    .font(.headline)
                    .foregroundColor(Color.quietly.textPrimary)

                Text("Set reading goals to track your progress and build a reading habit")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                viewModel.showAddGoal = true
            } label: {
                Label("Add Goal", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.quietly.primary)
        }
        .padding(40)
    }

    // MARK: - Add Goal Button
    private var addGoalButton: some View {
        Button {
            viewModel.showAddGoal = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Goal")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(Color.quietly.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.quietly.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            )
        }
    }

    // MARK: - Add Goal Sheet
    private var addGoalSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Goal type picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal Type")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    Picker("Goal Type", selection: $viewModel.newGoalType) {
                        ForEach(viewModel.availableTypes) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.quietly.secondary)
                    .cornerRadius(12)
                }

                // Target value
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    HStack {
                        TextField("Target", value: $viewModel.newTargetValue, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 100)

                        Text(viewModel.newGoalType.unit)
                            .foregroundColor(Color.quietly.textSecondary)

                        Text(viewModel.newGoalType.periodDescription)
                            .foregroundColor(Color.quietly.textMuted)
                    }
                }

                // Suggested values
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Set")
                        .font(.caption)
                        .foregroundColor(Color.quietly.textSecondary)

                    HStack(spacing: 12) {
                        ForEach(suggestedValues, id: \.self) { value in
                            Button {
                                viewModel.newTargetValue = value
                            } label: {
                                Text("\(value)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.newTargetValue == value
                                            ? Color.quietly.primary
                                            : Color.quietly.secondary
                                    )
                                    .foregroundColor(
                                        viewModel.newTargetValue == value
                                            ? Color.quietly.primaryForeground
                                            : Color.quietly.textPrimary
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                Spacer()

                Button {
                    viewModel.addGoal(context: modelContext)
                    // Show notification prompt after first goal
                    if !hasCheckedNotifications {
                        checkNotificationStatus()
                    }
                } label: {
                    Text("Create Goal")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.primary)
                .disabled(viewModel.newTargetValue <= 0)
            }
            .padding()
            .background(Color.quietly.background)
            .navigationTitle("Create Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showAddGoal = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private var suggestedValues: [Int] {
        switch viewModel.newGoalType {
        case .dailyMinutes:
            return [15, 30, 45, 60]
        case .weeklyMinutes:
            return [60, 120, 180, 300]
        case .booksPerMonth:
            return [1, 2, 3, 4]
        case .booksPerYear:
            return [6, 12, 24, 52]
        }
    }

    // MARK: - Notification Helpers
    private func checkNotificationStatus() {
        guard !hasCheckedNotifications else { return }
        hasCheckedNotifications = true

        // Don't show if dismissed before
        if UserDefaults.standard.bool(forKey: "dismissedGoalNotificationPrompt") { return }
        // Don't show if no goals
        if viewModel.progressList.isEmpty { return }
        // Don't show if notifications already enabled
        if UserDefaults.standard.bool(forKey: "dailyReminderEnabled") { return }

        Task {
            let status = await NotificationService.shared.checkPermissionStatus()
            await MainActor.run {
                if status == .notDetermined {
                    withAnimation {
                        showNotificationPrompt = true
                    }
                }
            }
        }
    }

    private func enableNotifications() async {
        let granted = await NotificationService.shared.requestPermission()
        await MainActor.run {
            if granted {
                // Enable daily reminder at 8 PM by default
                var components = DateComponents()
                components.hour = 20
                components.minute = 0
                NotificationService.shared.scheduleDailyReminder(at: components)
                UserDefaults.standard.set(true, forKey: "dailyReminderEnabled")
            }
            withAnimation {
                showNotificationPrompt = false
                UserDefaults.standard.set(true, forKey: "dismissedGoalNotificationPrompt")
            }
        }
    }
}

// MARK: - Time Goal Card (Larger, more prominent)
struct TimeGoalCard: View {
    let progress: GoalProgress
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: progress.goal.goalType.iconName)
                    .font(.title3)
                    .foregroundColor(progress.isComplete ? Color.quietly.success : Color.quietly.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(progress.goal.goalType.displayName)
                        .font(.headline)
                        .foregroundColor(Color.quietly.textPrimary)

                    Text(progress.goal.goalType.periodDescription)
                        .font(.caption)
                        .foregroundColor(Color.quietly.textSecondary)
                }

                Spacer()

                if progress.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.quietly.success)
                }

                if let onDelete = onDelete {
                    Menu {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("Delete Goal", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color.quietly.textMuted)
                            .padding(8)
                    }
                }
            }

            // Progress
            VStack(spacing: 8) {
                HStack(alignment: .lastTextBaseline) {
                    Text("\(progress.currentValue)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color.quietly.textPrimary)

                    Text("/ \(progress.targetValue) \(progress.goal.goalType.unit)")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    Spacer()

                    Text("\(progress.progressPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(progress.isComplete ? Color.quietly.success : Color.quietly.textSecondary)
                }

                ProgressView(value: progress.progress)
                    .tint(progress.isComplete ? Color.quietly.success : Color.quietly.accent)
            }
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(16)
    }
}

// MARK: - Compact Goal Card (For book counts)
struct CompactGoalCard: View {
    let progress: GoalProgress
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: progress.goal.goalType.iconName)
                    .font(.caption)
                    .foregroundColor(progress.isComplete ? Color.quietly.success : Color.quietly.accent)

                Spacer()

                if let onDelete = onDelete {
                    Menu {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .foregroundColor(Color.quietly.textMuted)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(progress.currentValue)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.quietly.textPrimary)

                    Text("/\(progress.targetValue)")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textMuted)
                }

                Text(progress.goal.goalType == .booksPerMonth ? "this month" : "this year")
                    .font(.caption)
                    .foregroundColor(Color.quietly.textSecondary)
            }

            ProgressView(value: progress.progress)
                .tint(progress.isComplete ? Color.quietly.success : Color.quietly.accent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.quietly.card)
        .cornerRadius(12)
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
