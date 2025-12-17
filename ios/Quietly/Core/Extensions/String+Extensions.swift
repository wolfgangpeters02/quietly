import Foundation

extension String {
    // MARK: - Validation
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }

    var isValidPassword: Bool {
        count >= AppConstants.Validation.minPasswordLength
    }

    var isValidISBN: Bool {
        let cleaned = self.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
        return cleaned.count == 10 || cleaned.count == 13
    }

    // MARK: - Trimming
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nilIfEmpty: String? {
        trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - ISBN Formatting
    var cleanedISBN: String {
        replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Truncation
    func truncated(to length: Int, trailing: String = "...") -> String {
        if count > length {
            return String(prefix(length)) + trailing
        }
        return self
    }

    // MARK: - Capitalization
    var sentenceCapitalized: String {
        guard let first = first else { return self }
        return String(first).uppercased() + dropFirst()
    }

    // MARK: - URL Encoding
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

// MARK: - Optional String Extension
extension Optional where Wrapped == String {
    var orEmpty: String {
        self ?? ""
    }

    var isNilOrEmpty: Bool {
        self?.trimmed.isEmpty ?? true
    }
}
