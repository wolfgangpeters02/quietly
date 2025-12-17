import SwiftUI
import SwiftData
import TipKit

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GoalsViewModel()
    @State private var addButtonTrigger = false

    // Tips
    private let setGoalTip = SetGoalTip()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Tip
                    if viewModel.progressList.isEmpty {
                        TipView(setGoalTip)
                    }

                    // Add goal section
                    if viewModel.canAddMoreGoals {
                        addGoalSection
                    }

                    // Goals list
                    if viewModel.progressList.isEmpty && !viewModel.isLoading {
                        EmptyStateView(
                            icon: "target",
                            title: "No goals yet",
                            message: "Set reading goals to track your progress",
                            actionTitle: viewModel.canAddMoreGoals ? "Add Goal" : nil
                        ) {
                            viewModel.showAddGoal = true
                        }
                    } else {
                        VStack(spacing: 16) {
                            ForEach(viewModel.progressList) { progress in
                                GoalCard(progress: progress) {
                                    viewModel.deleteGoal(progress.goal, context: modelContext)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.quietly.background)
            .navigationTitle("Reading Goals")
            .refreshable {
                viewModel.refresh(context: modelContext)
            }
            .onAppear {
                viewModel.loadData(context: modelContext)
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

    // MARK: - Add Goal Section
    private var addGoalSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Add New Goal")
                    .font(.headline)
                    .foregroundColor(Color.quietly.textPrimary)

                Spacer()

                Button {
                    addButtonTrigger.toggle()
                    viewModel.showAddGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.quietly.primary)
                        .symbolEffect(.bounce, value: addButtonTrigger)
                }
            }

            // Quick add buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableTypes) { type in
                        GoalTypeButton(type: type) {
                            viewModel.newGoalType = type
                            viewModel.newTargetValue = viewModel.suggestedTarget
                            viewModel.showAddGoal = true
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Add Goal Sheet
    private var addGoalSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Create Reading Goal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.quietly.textPrimary)

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
                                            ? .white
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showAddGoal = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
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
}

// MARK: - Goal Type Button with Animation
struct GoalTypeButton: View {
    let type: GoalType
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            isPressed.toggle()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: type.iconName)
                    .symbolEffect(.bounce, value: isPressed)
                Text(type.displayName)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.quietly.secondary)
            .foregroundColor(Color.quietly.textPrimary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    GoalsView()
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
