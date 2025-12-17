import Foundation
import Supabase
import Combine

@MainActor
final class AuthService: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?

    // MARK: - Private Properties
    private let client = SupabaseManager.shared.client
    private var authStateListener: Task<Void, Never>?

    // MARK: - Initialization
    init() {
        setupAuthStateListener()
    }

    deinit {
        authStateListener?.cancel()
    }

    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateListener = Task { [weak self] in
            for await (event, session) in self?.client.auth.authStateChanges ?? AsyncStream { _ in } {
                guard let self = self else { return }

                await MainActor.run {
                    switch event {
                    case .signedIn:
                        self.currentUser = session?.user
                        self.isAuthenticated = true
                    case .signedOut:
                        self.currentUser = nil
                        self.isAuthenticated = false
                    case .tokenRefreshed:
                        self.currentUser = session?.user
                    default:
                        break
                    }
                }
            }
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            currentUser = session.user
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, fullName: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let session = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )
            currentUser = session.user
            isAuthenticated = true

            // Create profile record
            if let userId = session.user?.id {
                try await createProfile(userId: userId, fullName: fullName)
            }
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign Out
    func signOut() async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            try await client.auth.signOut()
            currentUser = nil
            isAuthenticated = false
            KeychainHelper.clearAuthData()
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Restore Session
    func restoreSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await client.auth.session
            currentUser = session.user
            isAuthenticated = true
        } catch {
            currentUser = nil
            isAuthenticated = false
        }
    }

    // MARK: - Reset Password
    func resetPassword(email: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            try await client.auth.resetPasswordForEmail(email)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Update Password
    func updatePassword(newPassword: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            try await client.auth.update(user: UserAttributes(password: newPassword))
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Create Profile
    private func createProfile(userId: UUID, fullName: String) async throws {
        let profile = ["id": userId.uuidString, "full_name": fullName]

        try await client.database
            .from(SupabaseTable.profiles.rawValue)
            .upsert(profile)
            .execute()
    }

    // MARK: - Get Profile
    func getProfile() async throws -> Profile? {
        guard let userId = currentUser?.id else { return nil }

        let response: [Profile] = try await client.database
            .from(SupabaseTable.profiles.rawValue)
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return response.first
    }

    // MARK: - Update Profile
    func updateProfile(fullName: String) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.notAuthenticated
        }

        try await client.database
            .from(SupabaseTable.profiles.rawValue)
            .update(["full_name": fullName])
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Clear Error
    func clearError() {
        error = nil
    }
}
