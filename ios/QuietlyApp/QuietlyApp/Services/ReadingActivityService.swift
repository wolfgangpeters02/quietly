import Foundation
import ActivityKit
import SwiftUI

/// Service for managing Reading Session Live Activities
@MainActor
final class ReadingActivityService: ObservableObject {
    static let shared = ReadingActivityService()

    @Published private(set) var currentActivity: Activity<ReadingActivityAttributes>?

    private init() {}

    /// Check if Live Activities are supported
    var isSupported: Bool {
        guard #available(iOS 16.1, *) else { return false }
        return ActivityAuthorizationInfo().areActivitiesEnabled
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
            currentPage: startPage,
            timerStartDate: Date()
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

        // Calculate the effective start time for the timer
        // This is now - elapsedSeconds, so the timer shows correct time
        let timerStartDate = Date().addingTimeInterval(-Double(elapsedSeconds))

        let state = ReadingActivityAttributes.ContentState(
            elapsedSeconds: elapsedSeconds,
            isPaused: isPaused,
            startPage: nil, // Preserved from initial state
            currentPage: currentPage,
            timerStartDate: timerStartDate
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
