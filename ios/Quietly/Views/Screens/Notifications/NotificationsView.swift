import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            List {
                // Permission section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notification Status")
                                .font(.subheadline)
                                .foregroundColor(Color.quietly.textPrimary)

                            Text(viewModel.permissionStatusText)
                                .font(.caption)
                                .foregroundColor(
                                    viewModel.canEnableReminders
                                        ? Color.quietly.success
                                        : Color.quietly.textSecondary
                                )
                        }

                        Spacer()

                        if !viewModel.canEnableReminders {
                            if viewModel.permissionStatus == .notDetermined {
                                Button("Enable") {
                                    Task { await viewModel.requestPermission() }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.quietly.primary)
                            } else {
                                Button("Settings") {
                                    viewModel.openSettings()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                } header: {
                    Text("Permissions")
                }

                // Daily reminder section
                Section {
                    Toggle("Daily Reading Reminder", isOn: Binding(
                        get: { viewModel.dailyReminderEnabled },
                        set: { _ in viewModel.toggleDailyReminder() }
                    ))
                    .disabled(!viewModel.canEnableReminders)

                    if viewModel.dailyReminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: { viewModel.reminderTime },
                                set: { viewModel.updateReminderTime($0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Daily Reminder")
                } footer: {
                    Text("Get a reminder to read at your preferred time each day")
                }

                // Other notifications section
                Section {
                    Toggle("Goal Achievement", isOn: Binding(
                        get: { viewModel.goalNotifications },
                        set: { _ in viewModel.toggleGoalNotifications() }
                    ))
                    .disabled(!viewModel.canEnableReminders)

                    Toggle("Reading Streak", isOn: Binding(
                        get: { viewModel.streakNotifications },
                        set: { _ in viewModel.toggleStreakNotifications() }
                    ))
                    .disabled(!viewModel.canEnableReminders)

                    Toggle("Book Completion", isOn: Binding(
                        get: { viewModel.completionNotifications },
                        set: { _ in viewModel.toggleCompletionNotifications() }
                    ))
                    .disabled(!viewModel.canEnableReminders)
                } header: {
                    Text("Notifications")
                }

                // Test section
                if viewModel.canEnableReminders {
                    Section {
                        Button {
                            viewModel.sendTestNotification()
                        } label: {
                            HStack {
                                Image(systemName: "bell.badge")
                                Text("Send Test Notification")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .task {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    NotificationsView()
}
