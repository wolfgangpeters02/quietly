import Foundation
import Supabase

// MARK: - Supabase Manager (Singleton)
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConstants.Supabase.url,
            supabaseKey: AppConstants.Supabase.anonKey
        )
    }
}

// MARK: - Database Tables
enum SupabaseTable: String {
    case profiles
    case books
    case userBooks = "user_books"
    case readingSessions = "reading_sessions"
    case notes
    case readingGoals = "reading_goals"
    case notificationSettings = "notification_settings"
    case userRoles = "user_roles"
}

// MARK: - Supabase Error
enum SupabaseError: LocalizedError {
    case notAuthenticated
    case networkError(Error)
    case decodingError(Error)
    case databaseError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data error: \(error.localizedDescription)"
        case .databaseError(let message):
            return message
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Convenience Extensions
extension SupabaseManager {
    var database: PostgrestClient {
        client.database
    }

    var auth: AuthClient {
        client.auth
    }

    var currentUserId: UUID? {
        try? client.auth.session.user.id
    }

    func requireUserId() throws -> UUID {
        guard let userId = currentUserId else {
            throw SupabaseError.notAuthenticated
        }
        return userId
    }
}
