import Foundation

enum AppConstants {
    // MARK: - Supabase Configuration
    enum Supabase {
        static let projectId = "vmfrjxodsgfjjigharxm"
        static let url = URL(string: "https://vmfrjxodsgfjjigharxm.supabase.co")!
        static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZtZnJqeG9kc2dmamppZ2hhcnhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MTE1MzUsImV4cCI6MjA3NzI4NzUzNX0.nYUHnoUyxiAF6qUkAHPW9BLXPbmnCfHc6q1eyYj1peU"
    }

    // MARK: - OpenLibrary API
    enum OpenLibrary {
        static let baseUrl = "https://openlibrary.org"
        static let searchUrl = "\(baseUrl)/search.json"
        static let isbnUrl = "\(baseUrl)/isbn"
        static let worksUrl = "\(baseUrl)/works"
        static let authorsUrl = "\(baseUrl)/authors"
        static let coversUrl = "https://covers.openlibrary.org/b/id"

        static func coverUrl(id: Int, size: CoverSize = .large) -> URL? {
            URL(string: "\(coversUrl)/\(id)-\(size.rawValue).jpg")
        }

        enum CoverSize: String {
            case small = "S"
            case medium = "M"
            case large = "L"
        }
    }

    // MARK: - App Info
    enum App {
        static let name = "Quietly"
        static let tagline = "Track your reading journey"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - UI Constants
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 16
        static let gridSpacing: CGFloat = 16
        static let bookAspectRatio: CGFloat = 2.0 / 3.0

        static let animationDuration: Double = 0.3
    }

    // MARK: - Timer Constants
    enum Timer {
        static let updateInterval: TimeInterval = 1.0
    }

    // MARK: - Validation
    enum Validation {
        static let minPasswordLength = 6
        static let maxTitleLength = 200
        static let maxNoteLength = 5000
    }

    // MARK: - Keychain Keys
    enum Keychain {
        static let accessToken = "quietly.access_token"
        static let refreshToken = "quietly.refresh_token"
        static let userId = "quietly.user_id"
    }

    // MARK: - UserDefaults Keys
    enum UserDefaults {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let lastReadingReminderTime = "lastReadingReminderTime"
        static let notificationsEnabled = "notificationsEnabled"
    }
}
