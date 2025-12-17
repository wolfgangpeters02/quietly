import SwiftUI

@main
struct QuietlyApp: App {
    @StateObject private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isCheckingSession = true

    var body: some View {
        Group {
            if isCheckingSession {
                // Splash screen
                SplashView()
            } else if authService.isAuthenticated {
                // Main app
                MainTabView()
            } else {
                // Landing/Auth
                LandingView()
            }
        }
        .task {
            await authService.restoreSession()
            isCheckingSession = false
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.quietly.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.quietly.primary)

                Text(AppConstants.App.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.quietly.textPrimary)

                ProgressView()
                    .tint(Color.quietly.primary)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
