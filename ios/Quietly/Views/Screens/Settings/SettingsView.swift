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

                    NavigationLink {
                        NotificationsView()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink {
                        GoalsView()
                    } label: {
                        Label("Reading Goals", systemImage: "target")
                    }

                    NavigationLink {
                        NotesView()
                    } label: {
                        Label("Notes & Quotes", systemImage: "note.text")
                    }
                } header: {
                    Text("Features")
                }

                // About section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(AppConstants.App.version) (\(AppConstants.App.build))")
                            .foregroundColor(Color.quietly.textSecondary)
                    }

                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Text("Source Code")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(Color.quietly.textSecondary)
                        }
                    }
                } header: {
                    Text("About")
                }

                // Data section
                Section {
                    HStack {
                        Image(systemName: "externaldrive.fill")
                            .foregroundColor(Color.quietly.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Local Storage")
                                .font(.subheadline)
                            Text("Your data is stored locally on this device")
                                .font(.caption)
                                .foregroundColor(Color.quietly.textSecondary)
                        }
                    }
                } header: {
                    Text("Data")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
