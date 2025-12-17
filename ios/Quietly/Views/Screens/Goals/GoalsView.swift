import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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
                                    Task { await viewModel.deleteGoal(progress.goal) }
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
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
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
                    viewModel.showAddGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.quietly.primary)
                }
            }

            // Quick add buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableTypes) { type in
                        Button {
                            viewModel.newGoalType = type
                            viewModel.newTargetValue = viewModel.suggestedTarget
                            viewModel.showAddGoal = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: type.iconName)
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
                    Task { await viewModel.addGoal() }
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

#Preview {
    GoalsView()
}
