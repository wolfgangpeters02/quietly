package com.quietly.app.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.FloatingActionButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles
import kotlinx.coroutines.delay

@Composable
fun ReadingTimer(
    startTimeMillis: Long,
    totalPausedSeconds: Int,
    isPaused: Boolean,
    pausedAtMillis: Long?,
    onPauseResume: () -> Unit,
    onStop: () -> Unit,
    modifier: Modifier = Modifier
) {
    var currentTime by remember { mutableLongStateOf(System.currentTimeMillis()) }

    // Update timer every second
    LaunchedEffect(isPaused) {
        while (!isPaused) {
            currentTime = System.currentTimeMillis()
            delay(1000)
        }
    }

    // Calculate elapsed time
    val elapsedSeconds = if (isPaused && pausedAtMillis != null) {
        ((pausedAtMillis - startTimeMillis) / 1000).toInt() - totalPausedSeconds
    } else {
        ((currentTime - startTimeMillis) / 1000).toInt() - totalPausedSeconds
    }

    val hours = elapsedSeconds / 3600
    val minutes = (elapsedSeconds % 3600) / 60
    val seconds = elapsedSeconds % 60

    val timeString = String.format("%02d:%02d:%02d", hours, minutes, seconds)

    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Timer display
        Text(
            text = timeString,
            style = QuietlyTextStyles.TimerDisplay,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(vertical = 32.dp)
        )

        // Status text
        Text(
            text = if (isPaused) "Paused" else "Reading...",
            style = QuietlyTextStyles.StatLabel,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Control buttons
        Row(
            horizontalArrangement = Arrangement.spacedBy(24.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Pause/Resume button
            FloatingActionButton(
                onClick = onPauseResume,
                containerColor = if (isPaused) QuietlyColors.Accent else QuietlyColors.Primary,
                contentColor = QuietlyColors.TextOnPrimary,
                modifier = Modifier.size(72.dp),
                elevation = FloatingActionButtonDefaults.elevation(
                    defaultElevation = 4.dp
                )
            ) {
                Icon(
                    imageVector = if (isPaused) Icons.Default.PlayArrow else Icons.Default.Pause,
                    contentDescription = if (isPaused) "Resume" else "Pause",
                    modifier = Modifier.size(36.dp)
                )
            }

            // Stop button
            FloatingActionButton(
                onClick = onStop,
                containerColor = QuietlyColors.Error,
                contentColor = QuietlyColors.TextOnPrimary,
                modifier = Modifier.size(56.dp),
                elevation = FloatingActionButtonDefaults.elevation(
                    defaultElevation = 4.dp
                )
            ) {
                Icon(
                    imageVector = Icons.Default.Stop,
                    contentDescription = "Stop",
                    modifier = Modifier.size(28.dp)
                )
            }
        }
    }
}

@Composable
fun formatDuration(seconds: Int): String {
    val hours = seconds / 3600
    val minutes = (seconds % 3600) / 60

    return when {
        hours > 0 -> "${hours}h ${minutes}m"
        minutes > 0 -> "${minutes}m"
        else -> "${seconds}s"
    }
}
