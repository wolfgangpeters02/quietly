import SwiftUI

// MARK: - Quietly Design System Colors
extension Color {
    static let quietly = QuietlyColors.self
}

enum QuietlyColors {
    // MARK: - Primary Colors (Warm Brown)
    static let primary = Color(hex: "#514335")           // hsl(32 35% 38%) - Rich brown
    static let primaryForeground = Color(hex: "#F8F4ED") // hsl(38 22% 97%) - Warm cream

    // MARK: - Background Colors
    static let background = Color(hex: "#F5F1EB")        // hsl(38 22% 97%) - Warm cream
    static let card = Color.white
    static let cardBorder = Color(hex: "#E8E1D8")        // hsl(38 15% 88%)

    // MARK: - Accent Color (Sage Green)
    static let accent = Color(hex: "#69A279")            // hsl(150 25% 55%) - Sage green
    static let accentForeground = Color.white

    // MARK: - Secondary Colors
    static let secondary = Color(hex: "#E8E2D9")         // hsl(38 18% 92%)
    static let secondaryForeground = Color(hex: "#38362E") // hsl(32 18% 22%)

    // MARK: - Muted Colors
    static let muted = Color(hex: "#E8E5DF")             // hsl(38 15% 90%)
    static let mutedForeground = Color(hex: "#A0958A")   // hsl(32 10% 50%)

    // MARK: - Semantic Colors
    static let destructive = Color(hex: "#DC2626")       // Red for delete actions
    static let destructiveForeground = Color.white

    static let success = Color(hex: "#22C55E")           // Green for success states
    static let warning = Color(hex: "#F59E0B")           // Amber for warnings

    // MARK: - Text Colors
    static let textPrimary = Color(hex: "#382E24")       // hsl(32 18% 22%) - Dark brown
    static let textSecondary = Color(hex: "#6B5D4D")     // Lighter brown
    static let textMuted = Color(hex: "#A0958A")         // Muted brown

    // MARK: - Status Colors
    static let reading = accent                           // Sage green for "reading"
    static let completed = Color(hex: "#22C55E")         // Green for completed
    static let wantToRead = Color(hex: "#8B7355")        // Brown for "want to read"

    // MARK: - Shadow
    static let shadow = Color.black.opacity(0.05)
    static let shadowBook = Color(hex: "#514335").opacity(0.12)
}

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
