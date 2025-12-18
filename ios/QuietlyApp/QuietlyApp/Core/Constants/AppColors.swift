import SwiftUI
import UIKit

// MARK: - Quietly Design System Colors
// Single source of truth for all app colors with dark mode support

extension Color {
    static let quietly = QuietlyColors.self
}

enum QuietlyColors {
    // MARK: - Primary Colors (Warm Brown)
    /// Rich brown - main brand color for buttons, icons, accents
    static let primary = Color(dynamicLight: "#514335", dark: "#D4C4B0")

    /// Text on primary color backgrounds
    static let primaryForeground = Color(dynamicLight: "#F8F4ED", dark: "#1C1917")

    // MARK: - Background Colors
    /// Main app background - warm cream (light) / deep brown (dark)
    static let background = Color(dynamicLight: "#F5F1EB", dark: "#1C1917")

    /// Card/surface background
    static let card = Color(dynamicLight: "#FFFFFF", dark: "#292524")

    /// Card border color
    static let cardBorder = Color(dynamicLight: "#E8E1D8", dark: "#44403C")

    // MARK: - Accent Color (Sage Green)
    /// Sage green - used for progress, reading status, CTAs
    static let accent = Color(dynamicLight: "#69A279", dark: "#7DB88D")

    /// Text on accent backgrounds
    static let accentForeground = Color.white

    // MARK: - Secondary Colors
    /// Secondary background for badges, chips
    static let secondary = Color(dynamicLight: "#E8E2D9", dark: "#44403C")

    /// Text on secondary backgrounds
    static let secondaryForeground = Color(dynamicLight: "#38362E", dark: "#E7E5E4")

    // MARK: - Muted Colors
    /// Muted background for subtle UI elements
    static let muted = Color(dynamicLight: "#E8E5DF", dark: "#3D3835")

    /// Muted text color
    static let mutedForeground = Color(dynamicLight: "#A0958A", dark: "#A8A29E")

    // MARK: - Text Colors
    /// Primary text - dark brown (light) / cream (dark)
    static let textPrimary = Color(dynamicLight: "#382E24", dark: "#FAFAF9")

    /// Secondary text - medium brown
    static let textSecondary = Color(dynamicLight: "#6B5D4D", dark: "#A8A29E")

    /// Muted/tertiary text
    static let textMuted = Color(dynamicLight: "#A0958A", dark: "#78716C")

    // MARK: - Semantic Colors
    /// Destructive actions (delete, remove)
    static let destructive = Color(dynamicLight: "#DC2626", dark: "#EF4444")
    static let destructiveForeground = Color.white

    /// Success states
    static let success = Color(dynamicLight: "#22C55E", dark: "#4ADE80")

    /// Warning states
    static let warning = Color(dynamicLight: "#F59E0B", dark: "#FBBF24")

    // MARK: - Status Colors (for reading status badges)
    /// Currently reading - uses accent
    static let reading = accent

    /// Completed books
    static let completed = success

    /// Want to read / queued
    static let wantToRead = Color(dynamicLight: "#8B7355", dark: "#A89078")

    // MARK: - Shadow Colors
    static let shadow = Color.black.opacity(0.05)
    static let shadowBook = Color(dynamicLight: "#514335", dark: "#000000").opacity(0.12)
    static let shadowElevated = Color(dynamicLight: "#514335", dark: "#000000").opacity(0.15)
    static let shadowSubtle = Color.black.opacity(0.03)

    // MARK: - Search Bar
    /// Search bar background
    static let searchBackground = Color(dynamicLight: "#E8E2D9", dark: "#292524")

    /// Search bar placeholder text
    static let searchPlaceholder = textMuted

    // MARK: - List/Form Styling
    /// List section header text
    static let listHeader = textSecondary

    /// List row background
    static let listRowBackground = card

    /// List section background (grouped style)
    static let listSectionBackground = Color(dynamicLight: "#EFEBE5", dark: "#1C1917")

    // MARK: - Gradients
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(dynamicLight: "#514335", dark: "#D4C4B0"),
                Color(dynamicLight: "#6B5D4D", dark: "#B8A896")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(dynamicLight: "#69A279", dark: "#7DB88D"),
                Color(dynamicLight: "#5A9469", dark: "#6DA87D")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var warmGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(dynamicLight: "#F5F1EB", dark: "#1C1917"),
                Color(dynamicLight: "#EDE8E0", dark: "#292524")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Glass Effects
    static let glassBackground = Color(dynamicLight: "#FFFFFF", dark: "#292524").opacity(0.7)
    static let glassBorder = Color(dynamicLight: "#FFFFFF", dark: "#44403C").opacity(0.3)
}

// MARK: - Dynamic Color Initializer
extension Color {
    /// Creates a color that adapts to light/dark mode
    /// - Parameters:
    ///   - light: Hex color for light mode
    ///   - dark: Hex color for dark mode
    init(dynamicLight light: String, dark: String) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(hex: dark)
            default:
                return UIColor(hex: light)
            }
        })
    }

    /// Creates a color from hex string (non-adaptive)
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

// MARK: - UIColor Hex Extension
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
