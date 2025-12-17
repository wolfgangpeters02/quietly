package com.quietly.app.ui.theme

import androidx.compose.ui.graphics.Color

object QuietlyColors {
    // Primary palette (matching iOS)
    val Primary = Color(0xFF514335)      // Warm brown
    val Background = Color(0xFFF5F1EB)   // Warm cream
    val Accent = Color(0xFF69A279)       // Sage green

    // Surface colors
    val Card = Color.White
    val Surface = Color.White
    val SurfaceVariant = Color(0xFFF8F6F3)

    // Text colors
    val TextPrimary = Color(0xFF382E24)
    val TextSecondary = Color(0xFF6B5D4D)
    val TextTertiary = Color(0xFF9B8B7A)
    val TextOnPrimary = Color.White
    val TextOnAccent = Color.White

    // Status colors
    val Success = Color(0xFF69A279)
    val Warning = Color(0xFFE5A84B)
    val Error = Color(0xFFD64545)
    val Info = Color(0xFF5B8FB9)

    // Reading status colors
    val WantToRead = Color(0xFF5B8FB9)   // Blue
    val Reading = Color(0xFFE5A84B)       // Amber/Orange
    val Completed = Color(0xFF69A279)     // Green (same as accent)

    // Additional UI colors
    val Divider = Color(0xFFE5DDD3)
    val Border = Color(0xFFD4C9BB)
    val Disabled = Color(0xFFBDB3A5)
    val Overlay = Color(0x80000000)

    // Star rating
    val StarFilled = Color(0xFFFFC107)
    val StarEmpty = Color(0xFFE0E0E0)
}

// Material 3 color scheme mappings
val md_theme_light_primary = QuietlyColors.Primary
val md_theme_light_onPrimary = QuietlyColors.TextOnPrimary
val md_theme_light_primaryContainer = Color(0xFFE8DFD5)
val md_theme_light_onPrimaryContainer = QuietlyColors.TextPrimary
val md_theme_light_secondary = QuietlyColors.Accent
val md_theme_light_onSecondary = QuietlyColors.TextOnAccent
val md_theme_light_secondaryContainer = Color(0xFFD5E8DA)
val md_theme_light_onSecondaryContainer = QuietlyColors.TextPrimary
val md_theme_light_tertiary = QuietlyColors.Info
val md_theme_light_onTertiary = Color.White
val md_theme_light_tertiaryContainer = Color(0xFFD5E5F0)
val md_theme_light_onTertiaryContainer = QuietlyColors.TextPrimary
val md_theme_light_error = QuietlyColors.Error
val md_theme_light_errorContainer = Color(0xFFF9DEDC)
val md_theme_light_onError = Color.White
val md_theme_light_onErrorContainer = Color(0xFF410E0B)
val md_theme_light_background = QuietlyColors.Background
val md_theme_light_onBackground = QuietlyColors.TextPrimary
val md_theme_light_surface = QuietlyColors.Surface
val md_theme_light_onSurface = QuietlyColors.TextPrimary
val md_theme_light_surfaceVariant = QuietlyColors.SurfaceVariant
val md_theme_light_onSurfaceVariant = QuietlyColors.TextSecondary
val md_theme_light_outline = QuietlyColors.Border
val md_theme_light_inverseOnSurface = QuietlyColors.Background
val md_theme_light_inverseSurface = QuietlyColors.TextPrimary
val md_theme_light_inversePrimary = Color(0xFFD4C4B5)
val md_theme_light_surfaceTint = QuietlyColors.Primary
val md_theme_light_outlineVariant = QuietlyColors.Divider
val md_theme_light_scrim = Color.Black
