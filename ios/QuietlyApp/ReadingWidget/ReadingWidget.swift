import WidgetKit
import SwiftUI
import ActivityKit

// MARK: - Widget Bundle
@main
struct ReadingWidgetBundle: WidgetBundle {
    var body: some Widget {
        ReadingActivityLiveActivity()
    }
}

// MARK: - Live Activity Configuration
struct ReadingActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReadingActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .foregroundColor(.green)
                        Text(context.state.isPaused ? "Paused" : "Reading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPaused {
                        Text(context.state.formattedTime)
                            .font(.system(.title3, design: .monospaced, weight: .semibold))
                            .monospacedDigit()
                    } else {
                        Text(timerInterval: context.state.timerInterval, countsDown: false)
                            .font(.system(.title3, design: .monospaced, weight: .semibold))
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 4) {
                        Text(context.attributes.bookTitle)
                            .font(.headline)
                            .lineLimit(1)
                        if let author = context.attributes.bookAuthor {
                            Text(author)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if context.state.pagesRead > 0 {
                            Text("\(context.state.pagesRead) pages read")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "book.fill")
                    .foregroundColor(.green)
            } compactTrailing: {
                if context.state.isPaused {
                    Text(context.state.formattedTime)
                        .font(.system(.caption, design: .monospaced))
                        .monospacedDigit()
                } else {
                    Text(timerInterval: context.state.timerInterval, countsDown: false)
                        .font(.system(.caption, design: .monospaced))
                        .monospacedDigit()
                }
            } minimal: {
                Image(systemName: "book.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ReadingActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Book icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }

            // Book info
            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.bookTitle)
                    .font(.headline)
                    .lineLimit(1)

                if let author = context.attributes.bookAuthor {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Timer
            VStack(alignment: .trailing, spacing: 4) {
                if context.state.isPaused {
                    // Show static time when paused
                    Text(context.state.formattedTime)
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .monospacedDigit()
                } else {
                    // Show live counting timer when reading
                    Text(timerInterval: context.state.timerInterval, countsDown: false)
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                }

                Text(context.state.isPaused ? "Paused" : "Reading")
                    .font(.caption)
                    .foregroundColor(context.state.isPaused ? .orange : .green)
            }
        }
        .padding()
        .activityBackgroundTint(Color(white: 0.1))
    }
}

// MARK: - Preview
#Preview("Lock Screen", as: .content, using: ReadingActivityAttributes(
    bookTitle: "The Great Gatsby",
    bookAuthor: "F. Scott Fitzgerald",
    startTime: Date()
)) {
    ReadingActivityLiveActivity()
} contentStates: {
    ReadingActivityAttributes.ContentState(
        elapsedSeconds: 1523,
        isPaused: false,
        startPage: 45,
        currentPage: 67,
        timerStartDate: Date().addingTimeInterval(-1523)
    )
    ReadingActivityAttributes.ContentState(
        elapsedSeconds: 1800,
        isPaused: true,
        startPage: 45,
        currentPage: 72,
        timerStartDate: Date().addingTimeInterval(-1800)
    )
}
