import UIKit

/// Service for providing haptic feedback throughout the app
/// Makes interactions feel more native and responsive
final class HapticService {
    static let shared = HapticService()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact - for subtle interactions like selections
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact - for button taps, toggles
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy impact - for significant actions like completing goals
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft impact - for gentle feedback
    func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Rigid impact - for firm feedback
    func rigidImpact() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success feedback - for completed actions, achievements
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning feedback - for cautionary actions
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error feedback - for failed actions
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed - for picker changes, segmented controls
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Contextual Haptics

    /// Feedback for starting a reading session
    func sessionStarted() {
        mediumImpact()
    }

    /// Feedback for pausing a reading session
    func sessionPaused() {
        lightImpact()
    }

    /// Feedback for resuming a reading session
    func sessionResumed() {
        lightImpact()
    }

    /// Feedback for ending a reading session
    func sessionEnded() {
        success()
    }

    /// Feedback for completing a goal
    func goalCompleted() {
        // Double tap pattern for celebration
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.success()
        }
    }

    /// Feedback for completing a book
    func bookCompleted() {
        // Triple success for big achievement
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.heavyImpact()
        }
    }

    /// Feedback for adding a book
    func bookAdded() {
        success()
    }

    /// Feedback for deleting something
    func deleted() {
        rigidImpact()
    }

    /// Feedback for scanning text
    func textScanned() {
        softImpact()
    }

    /// Feedback for streak milestone
    func streakMilestone() {
        heavyImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.success()
        }
    }

    /// Feedback for timer tick (every minute during reading)
    func timerTick() {
        softImpact()
    }

    /// Feedback for button tap
    func buttonTap() {
        lightImpact()
    }

    /// Feedback for toggle switch
    func toggle() {
        mediumImpact()
    }
}

// MARK: - SwiftUI View Modifier

import SwiftUI

struct HapticModifier: ViewModifier {
    let type: HapticType

    enum HapticType {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case selection
    }

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                switch type {
                case .light:
                    HapticService.shared.lightImpact()
                case .medium:
                    HapticService.shared.mediumImpact()
                case .heavy:
                    HapticService.shared.heavyImpact()
                case .success:
                    HapticService.shared.success()
                case .warning:
                    HapticService.shared.warning()
                case .error:
                    HapticService.shared.error()
                case .selection:
                    HapticService.shared.selectionChanged()
                }
            }
    }
}

extension View {
    /// Add haptic feedback to a view's tap gesture
    func hapticFeedback(_ type: HapticModifier.HapticType) -> some View {
        modifier(HapticModifier(type: type))
    }
}
