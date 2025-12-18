import Foundation

enum ValidationError: LocalizedError {
    case emptyField(String)
    case invalidEmail
    case passwordTooShort
    case invalidISBN
    case invalidPageNumber
    case titleTooLong
    case noteTooLong
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "\(field) is required"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .passwordTooShort:
            return "Password must be at least \(AppConstants.Validation.minPasswordLength) characters"
        case .invalidISBN:
            return "Please enter a valid ISBN (10 or 13 digits)"
        case .invalidPageNumber:
            return "Please enter a valid page number"
        case .titleTooLong:
            return "Title is too long (max \(AppConstants.Validation.maxTitleLength) characters)"
        case .noteTooLong:
            return "Note is too long (max \(AppConstants.Validation.maxNoteLength) characters)"
        case .custom(let message):
            return message
        }
    }
}

enum ValidationHelpers {
    // MARK: - Email Validation
    static func validateEmail(_ email: String) -> ValidationError? {
        let trimmed = email.trimmed
        if trimmed.isEmpty {
            return .emptyField("Email")
        }
        if !trimmed.isValidEmail {
            return .invalidEmail
        }
        return nil
    }

    // MARK: - Password Validation
    static func validatePassword(_ password: String) -> ValidationError? {
        if password.isEmpty {
            return .emptyField("Password")
        }
        if !password.isValidPassword {
            return .passwordTooShort
        }
        return nil
    }

    // MARK: - ISBN Validation
    static func validateISBN(_ isbn: String) -> ValidationError? {
        let cleaned = isbn.cleanedISBN
        if cleaned.isEmpty {
            return .emptyField("ISBN")
        }
        if !isbn.isValidISBN {
            return .invalidISBN
        }
        return nil
    }

    // MARK: - Book Title Validation
    static func validateBookTitle(_ title: String) -> ValidationError? {
        let trimmed = title.trimmed
        if trimmed.isEmpty {
            return .emptyField("Title")
        }
        if trimmed.count > AppConstants.Validation.maxTitleLength {
            return .titleTooLong
        }
        return nil
    }

    // MARK: - Note Validation
    static func validateNote(_ note: String) -> ValidationError? {
        let trimmed = note.trimmed
        if trimmed.isEmpty {
            return .emptyField("Note")
        }
        if trimmed.count > AppConstants.Validation.maxNoteLength {
            return .noteTooLong
        }
        return nil
    }

    // MARK: - Page Number Validation
    static func validatePageNumber(_ page: Int?, maxPage: Int? = nil) -> ValidationError? {
        guard let page = page else { return nil }
        if page < 0 {
            return .invalidPageNumber
        }
        if let max = maxPage, page > max {
            return .custom("Page number cannot exceed \(max)")
        }
        return nil
    }

    // MARK: - Full Name Validation
    static func validateFullName(_ name: String) -> ValidationError? {
        let trimmed = name.trimmed
        if trimmed.isEmpty {
            return .emptyField("Name")
        }
        return nil
    }

    // MARK: - Goal Target Validation
    static func validateGoalTarget(_ value: Int) -> ValidationError? {
        if value <= 0 {
            return .custom("Target must be greater than 0")
        }
        return nil
    }
}
