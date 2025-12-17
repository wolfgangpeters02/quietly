import Foundation
import Security

enum KeychainHelper {
    // MARK: - Save
    static func save(_ data: Data, for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func save(_ string: String, for key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, for: key)
    }

    // MARK: - Load
    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }

    static func loadString(key: String) -> String? {
        guard let data = load(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Clear All
    static func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Convenience Extensions
extension KeychainHelper {
    static func saveAccessToken(_ token: String) {
        _ = save(token, for: AppConstants.Keychain.accessToken)
    }

    static func getAccessToken() -> String? {
        loadString(key: AppConstants.Keychain.accessToken)
    }

    static func saveRefreshToken(_ token: String) {
        _ = save(token, for: AppConstants.Keychain.refreshToken)
    }

    static func getRefreshToken() -> String? {
        loadString(key: AppConstants.Keychain.refreshToken)
    }

    static func saveUserId(_ userId: String) {
        _ = save(userId, for: AppConstants.Keychain.userId)
    }

    static func getUserId() -> String? {
        loadString(key: AppConstants.Keychain.userId)
    }

    static func clearAuthData() {
        _ = delete(key: AppConstants.Keychain.accessToken)
        _ = delete(key: AppConstants.Keychain.refreshToken)
        _ = delete(key: AppConstants.Keychain.userId)
    }
}
