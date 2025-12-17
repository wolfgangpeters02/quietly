package com.quietly.app.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material.icons.filled.StarHalf
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.quietly.app.ui.theme.QuietlyColors

@Composable
fun StarRating(
    rating: Int,
    maxRating: Int = 5,
    onRatingChanged: ((Int) -> Unit)? = null,
    starSize: Dp = 24.dp,
    modifier: Modifier = Modifier
) {
    Row(modifier = modifier) {
        for (i in 1..maxRating) {
            val icon = if (i <= rating) Icons.Default.Star else Icons.Default.StarBorder
            val tint = if (i <= rating) QuietlyColors.StarFilled else QuietlyColors.StarEmpty

            Icon(
                imageVector = icon,
                contentDescription = "Star $i",
                tint = tint,
                modifier = Modifier
                    .size(starSize)
                    .then(
                        if (onRatingChanged != null) {
                            Modifier.clickable { onRatingChanged(i) }
                        } else {
                            Modifier
                        }
                    )
            )
        }
    }
}

@Composable
fun StarRatingDisplay(
    rating: Float,
    maxRating: Int = 5,
    starSize: Dp = 20.dp,
    modifier: Modifier = Modifier
) {
    Row(modifier = modifier) {
        for (i in 1..maxRating) {
            val icon = when {
                i <= rating.toInt() -> Icons.Default.Star
                i - 0.5f <= rating -> Icons.Default.StarHalf
                else -> Icons.Default.StarBorder
            }
            val tint = if (i <= rating + 0.5f) QuietlyColors.StarFilled else QuietlyColors.StarEmpty

            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = tint,
                modifier = Modifier.size(starSize)
            )
        }
    }
}
