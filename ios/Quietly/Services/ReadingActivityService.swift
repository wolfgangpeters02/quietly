import Foundation
import ActivityKit
import SwiftUI

/// Attributes for the Reading Session Live Activity
struct ReadingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var isPaused: Bool
        var startPage: Int?
        var currentPage: Int?

        var formattedTime: String {
            let hours = elapsedSeconds / 3600
            let minutes = (elapsedSeconds % 3600) / 60
            let seconds = elapsedSeconds % 60

            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            }
            return String(format: "%d:%02d", minutes, seconds)
        }

        var pagesRead: Int {
            guard let start = startPage, let current = currentPage else { return 0 }
            return max(0, current - start)
        }
    }

    // Fixed attributes (set at activity start)
    var bookTitle: String
    var bookAuthor: String?
    var startTime: Date
}

/// Service for managing Reading Session Live Activities
@MainActor
final class ReadingActivityService: ObservableObject {
    static let shared = ReadingActivityService()

    @Published private(set) var currentActivity: Activity<ReadingActivityAttributes>?

    private init() {}

    /// Check if Live Activities are supported
    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    /// Start a new reading session Live Activity
    func startActivity(
        bookTitle: String,
        bookAuthor: String?,
        startPage: Int?
    ) {
        guard isSupported else { return }

        // End any existing activity
        endActivity()

        let attributes = ReadingActivityAttributes(
            bookTitle: bookTitle,
            bookAuthor: bookAuthor,
            startTime: Date()
        )

        let initialState = ReadingActivityAttributes.ContentState(
            elapsedSeconds: 0,
            isPaused: false,
            startPage: startPage,
            currentPage: startPage
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    /// Update the Live Activity with new state
    func updateActivity(
        elapsedSeconds: Int,
        isPaused: Bool,
        currentPage: Int? = nil
    ) {
        guard let activity = currentActivity else { return }

        let state = ReadingActivityAttributes.ContentState(
            elapsedSeconds: elapsedSeconds,
            isPaused: isPaused,
            startPage: nil, // Preserved from initial state
            currentPage: currentPage
        )

        Task {
            await activity.update(
                ActivityContent(state: state, staleDate: nil)
            )
        }
    }

    /// End the current Live Activity
    func endActivity(showSummary: Bool = false) {
        guard let activity = currentActivity else { return }

        Task {
            if showSummary {
                // Keep on lock screen briefly to show completion
                await activity.end(
                    ActivityContent(
                        state: activity.content.state,
                        staleDate: Date().addingTimeInterval(60)
                    ),
                    dismissalPolicy: .after(Date().addingTimeInterval(30))
                )
            } else {
                await activity.end(dismissalPolicy: .immediate)
            }
        }

        currentActivity = nil
    }
}

// MARK: - Live Activity Views

struct ReadingActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReadingActivityAttributes.self) { context in
            // Lock Screen / Banner view
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view regions
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Reading", systemImage: "book.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(context.attributes.bookTitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.formattedTime)
                            .font(.system(.title3, design: .monospaced, weight: .bold))
                            .foregroundStyle(context.state.isPaused ? .secondary : .primary)

                        if context.state.isPaused {
                            Text("Paused")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if context.state.pagesRead > 0 {
                            Label("\(context.state.pagesRead) pages", systemImage: "doc.text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let author = context.attributes.bookAuthor {
                            Text(author)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "book.fill")
                    .foregroundStyle(context.state.isPaused ? .orange : .primary)
            } compactTrailing: {
                Text(context.state.formattedTime)
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundStyle(context.state.isPaused ? .secondary : .primary)
            } minimal: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "book.fill")
                    .foregroundStyle(context.state.isPaused ? .orange : .primary)
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<ReadingActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            // Book icon
            ZStack {
                Circle()
                    .fill(.quaternary)
                    .frame(width: 50, height: 50)
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.bookTitle)
                    .font(.headline)
                    .lineLimit(1)

                if let author = context.attributes.bookAuthor {
                    Text(author)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(context.state.formattedTime)
                    .font(.system(.title2, design: .monospaced, weight: .bold))
                    .foregroundStyle(context.state.isPaused ? .secondary : .primary)

                if context.state.isPaused {
                    Text("Paused")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else if context.state.pagesRead > 0 {
                    Text("\(context.state.pagesRead) pages")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.8))
    }
}
