import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var isSignUp = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    // MARK: - Dependencies
    private let authService: AuthService

    // MARK: - Initialization
    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    // MARK: - Validation
    var isFormValid: Bool {
        let emailValid = email.isValidEmail
        let passwordValid = password.isValidPassword

        if isSignUp {
            return emailValid && passwordValid && !fullName.trimmed.isEmpty
        }
        return emailValid && passwordValid
    }

    var emailError: String? {
        guard !email.isEmpty else { return nil }
        return email.isValidEmail ? nil : "Please enter a valid email"
    }

    var passwordError: String? {
        guard !password.isEmpty else { return nil }
        return password.isValidPassword ? nil : "Password must be at least 6 characters"
    }

    // MARK: - Actions
    func signIn() async {
        guard isFormValid else {
            showValidationError()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signIn(email: email.trimmed, password: password)
            clearForm()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func signUp() async {
        guard isFormValid else {
            showValidationError()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signUp(
                email: email.trimmed,
                password: password,
                fullName: fullName.trimmed
            )
            clearForm()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func submit() async {
        if isSignUp {
            await signUp()
        } else {
            await signIn()
        }
    }

    func toggleMode() {
        withAnimation {
            isSignUp.toggle()
            errorMessage = nil
        }
    }

    func resetPassword() async {
        guard email.isValidEmail else {
            errorMessage = "Please enter your email address first"
            showError = true
            return
        }

        isLoading = true

        do {
            try await authService.resetPassword(email: email.trimmed)
            errorMessage = "Password reset email sent!"
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    // MARK: - Private Methods
    private func showValidationError() {
        if !email.isValidEmail {
            errorMessage = "Please enter a valid email address"
        } else if !password.isValidPassword {
            errorMessage = "Password must be at least 6 characters"
        } else if isSignUp && fullName.trimmed.isEmpty {
            errorMessage = "Please enter your name"
        }
        showError = true
    }

    private func clearForm() {
        email = ""
        password = ""
        fullName = ""
    }

    func clearError() {
        errorMessage = nil
        showError = false
    }
}
