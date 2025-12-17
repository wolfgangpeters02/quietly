package com.quietly.app.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.quietly.app.R

// Use system fonts (similar to SF Pro on iOS)
val QuietlyFontFamily = FontFamily.Default

// Monospace font for timer display
val MonospaceFontFamily = FontFamily.Monospace

val QuietlyTypography = Typography(
    // Display styles
    displayLarge = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp,
        color = QuietlyColors.TextPrimary
    ),
    displayMedium = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 45.sp,
        lineHeight = 52.sp,
        letterSpacing = 0.sp,
        color = QuietlyColors.TextPrimary
    ),
    displaySmall = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 36.sp,
        lineHeight = 44.sp,
        letterSpacing = 0.sp,
        color = QuietlyColors.TextPrimary
    ),

    // Headline styles
    headlineLarge = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = 0.sp,
        color = QuietlyColors.TextPrimary
    ),
    headlineMedium = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        letterSpacing = 0.sp,
        color = QuietlyColors.TextPrimary
    ),
    headlineSmall = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        letterSpacing = 0.sp,
        color = QuietlyColors.TextPrimary
    ),

    // Title styles
    titleLarge = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp,
        color = QuietlyColors.TextPrimary
    ),
    titleMedium = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp,
        color = QuietlyColors.TextPrimary
    ),
    titleSmall = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
        color = QuietlyColors.TextPrimary
    ),

    // Body styles
    bodyLarge = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp,
        color = QuietlyColors.TextPrimary
    ),
    bodyMedium = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp,
        color = QuietlyColors.TextSecondary
    ),
    bodySmall = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp,
        color = QuietlyColors.TextSecondary
    ),

    // Label styles
    labelLarge = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
        color = QuietlyColors.TextPrimary
    ),
    labelMedium = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
        color = QuietlyColors.TextSecondary
    ),
    labelSmall = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Medium,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
        color = QuietlyColors.TextTertiary
    )
)

// Custom text styles for specific use cases
object QuietlyTextStyles {
    val TimerDisplay = TextStyle(
        fontFamily = MonospaceFontFamily,
        fontWeight = FontWeight.Light,
        fontSize = 72.sp,
        lineHeight = 80.sp,
        letterSpacing = 2.sp,
        color = QuietlyColors.TextPrimary
    )

    val StatValue = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Bold,
        fontSize = 28.sp,
        lineHeight = 34.sp,
        color = QuietlyColors.TextPrimary
    )

    val StatLabel = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        color = QuietlyColors.TextSecondary
    )

    val BookTitle = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 16.sp,
        lineHeight = 22.sp,
        color = QuietlyColors.TextPrimary
    )

    val BookAuthor = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 18.sp,
        color = QuietlyColors.TextSecondary
    )

    val Quote = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 26.sp,
        letterSpacing = 0.3.sp,
        color = QuietlyColors.TextPrimary
    )

    val ButtonText = TextStyle(
        fontFamily = QuietlyFontFamily,
        fontWeight = FontWeight.SemiBold,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    )
}
