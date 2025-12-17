package com.quietly.app.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccessTime
import androidx.compose.material.icons.filled.Book
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.quietly.app.data.model.GoalType
import com.quietly.app.data.model.ReadingGoal
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles
import com.quietly.app.ui.theme.QuietlyTypography

@Composable
fun GoalCard(
    goal: ReadingGoal,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val progress = if (goal.targetValue > 0) {
        (goal.currentValue.toFloat() / goal.targetValue.toFloat()).coerceIn(0f, 1f)
    } else 0f

    val (icon, title, unit) = getGoalInfo(goal.goalType)
    val isCompleted = goal.currentValue >= goal.targetValue

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = QuietlyColors.Card
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = 2.dp
        )
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            // Header
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = if (isCompleted) QuietlyColors.Success else QuietlyColors.Primary
                )
                Text(
                    text = title,
                    style = QuietlyTypography.titleMedium,
                    modifier = Modifier.padding(start = 8.dp)
                )
            }

            // Progress text
            Row(
                modifier = Modifier.padding(top = 12.dp),
                verticalAlignment = Alignment.Baseline
            ) {
                Text(
                    text = "${goal.currentValue}",
                    style = QuietlyTextStyles.StatValue.copy(
                        color = if (isCompleted) QuietlyColors.Success else QuietlyColors.TextPrimary
                    )
                )
                Text(
                    text = " / ${goal.targetValue} $unit",
                    style = QuietlyTextStyles.StatLabel
                )
            }

            // Progress bar
            LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp)
                    .clip(RoundedCornerShape(4.dp)),
                color = if (isCompleted) QuietlyColors.Success else QuietlyColors.Accent,
                trackColor = QuietlyColors.Divider
            )

            // Status text
            Text(
                text = if (isCompleted) "Completed!" else "${(progress * 100).toInt()}% complete",
                style = QuietlyTextStyles.StatLabel.copy(
                    color = if (isCompleted) QuietlyColors.Success else QuietlyColors.TextSecondary
                ),
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }
}

private fun getGoalInfo(goalType: GoalType): Triple<ImageVector, String, String> {
    return when (goalType) {
        GoalType.DAILY_MINUTES -> Triple(Icons.Default.AccessTime, "Daily Reading", "minutes")
        GoalType.WEEKLY_MINUTES -> Triple(Icons.Default.CalendarToday, "Weekly Reading", "minutes")
        GoalType.BOOKS_PER_MONTH -> Triple(Icons.Default.CalendarMonth, "Monthly Books", "books")
        GoalType.BOOKS_PER_YEAR -> Triple(Icons.Default.Book, "Yearly Books", "books")
    }
}
