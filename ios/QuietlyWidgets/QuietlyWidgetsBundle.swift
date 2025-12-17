import WidgetKit
import SwiftUI

@main
struct QuietlyWidgetsBundle: WidgetBundle {
    var body: some Widget {
        ReadingProgressWidget()
        ReadingStatsWidget()
        ReadingStreakWidget()
    }
}
