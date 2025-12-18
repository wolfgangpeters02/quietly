import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                // App section
                Section {
                    NavigationLink {
                        ReadingHistoryView()
                    } label: {
                        Label("Reading History", systemImage: "calendar")
                    }
                    .listRowBackground(Color.quietly.card)

                    NavigationLink {
                        NotificationsView()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    .listRowBackground(Color.quietly.card)
                } header: {
                    Text("Features")
                        .foregroundColor(Color.quietly.textSecondary)
                }

                // About section
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(Color.quietly.textPrimary)
                        Spacer()
                        Text("\(AppConstants.App.version) (\(AppConstants.App.build))")
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                    .listRowBackground(Color.quietly.card)
                } header: {
                    Text("About")
                        .foregroundColor(Color.quietly.textSecondary)
                }

                // Data section
                Section {
                    HStack {
                        Image(systemName: "externaldrive.fill")
                            .foregroundColor(Color.quietly.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Local Storage")
                                .font(.subheadline)
                                .foregroundColor(Color.quietly.textPrimary)
                            Text("Your data is stored locally on this device")
                                .font(.caption)
                                .foregroundColor(Color.quietly.textSecondary)
                        }
                    }
                    .listRowBackground(Color.quietly.card)
                } header: {
                    Text("Data")
                        .foregroundColor(Color.quietly.textSecondary)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.quietly.background)
            .navigationTitle("Settings")
            .tint(Color.quietly.primary)
        }
    }
}

#Preview {
    SettingsView()
}
