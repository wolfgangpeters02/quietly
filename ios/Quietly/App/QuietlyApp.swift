import SwiftUI
import SwiftData
import UserNotifications
import TipKit

@main
struct QuietlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Configure TipKit
        QuietlyTips.configure()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Book.self,
            UserBook.self,
            Note.self,
            ReadingSession.self,
            ReadingGoal.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Update quick actions when app appears
                    QuickActionsService.shared.updateQuickActions()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Initialize quick actions
        QuickActionsService.shared.updateQuickActions()

        return true
    }

    // MARK: - Quick Actions

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        Task { @MainActor in
            let handled = QuickActionsService.shared.handleQuickAction(shortcutItem)
            completionHandler(handled)
        }
    }

    // MARK: - Notification Delegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notifications even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification actions
        let actionIdentifier = response.actionIdentifier

        if actionIdentifier != UNNotificationDefaultActionIdentifier &&
           actionIdentifier != UNNotificationDismissActionIdentifier {
            NotificationService.shared.handleNotificationAction(actionIdentifier, for: response.notification)
        }

        completionHandler()
    }
}

struct ContentView: View {
    @State private var isLoading = true
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        Group {
            if isLoading {
                SplashView()
            } else if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
        .task {
            // Brief splash screen delay for smooth UX
            try? await Task.sleep(for: .milliseconds(500))
            isLoading = false
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
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
