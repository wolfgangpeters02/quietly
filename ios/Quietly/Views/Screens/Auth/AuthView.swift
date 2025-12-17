import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.quietly.primary)

                    Text(AppConstants.App.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.quietly.textPrimary)

                    Text(AppConstants.App.tagline)
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                }
                .padding(.top, 60)

                // Form
                VStack(spacing: 20) {
                    // Name field (sign up only)
                    if viewModel.isSignUp {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.quietly.textSecondary)

                            TextField("Your name", text: $viewModel.fullName)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)
                                .autocapitalization(.words)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.quietly.textSecondary)

                        TextField("your@email.com", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.quietly.textSecondary)

                        SecureField("Enter password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(viewModel.isSignUp ? .newPassword : .password)
                    }

                    // Submit button
                    Button {
                        Task {
                            await viewModel.submit()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(viewModel.isSignUp ? "Create Account" : "Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(viewModel.isLoading || !viewModel.isFormValid)
                    .opacity(viewModel.isFormValid ? 1 : 0.6)

                    // Forgot password (sign in only)
                    if !viewModel.isSignUp {
                        Button {
                            Task {
                                await viewModel.resetPassword()
                            }
                        } label: {
                            Text("Forgot password?")
                                .font(.subheadline)
                                .foregroundColor(Color.quietly.primary)
                        }
                    }
                }
                .padding(.horizontal)

                // Toggle mode
                HStack {
                    Text(viewModel.isSignUp ? "Already have an account?" : "Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    Button(viewModel.isSignUp ? "Sign In" : "Sign Up") {
                        viewModel.toggleMode()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.quietly.primary)
                }
            }
            .padding()
        }
        .background(Color.quietly.background)
        .alert("Notice", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSignUp)
    }
}

#Preview {
    AuthView()
}
