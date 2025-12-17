import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Account section
                Section {
                    if let email = authService.currentUser?.email {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.quietly.primary)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Signed in as")
                                    .font(.caption)
                                    .foregroundColor(Color.quietly.textSecondary)

                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(Color.quietly.textPrimary)
                            }
                        }
                    }
                } header: {
                    Text("Account")
                }

                // App section
                Section {
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

                // Sign out
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await authService.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
}
