import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ReadingStreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReadingStreakEntry {
        ReadingStreakEntry(
            date: Date(),
            streakDays: 7,
            todayComplete: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ReadingStreakEntry) -> Void) {
        let data = WidgetDataReader.getReadingData()
        let entry = ReadingStreakEntry(
            date: Date(),
            streakDays: data.currentStreak,
            todayComplete: data.dailyGoalProgress >= 1.0
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReadingStreakEntry>) -> Void) {
        let data = WidgetDataReader.getReadingData()
        let entry = ReadingStreakEntry(
            date: Date(),
            streakDays: data.currentStreak,
            todayComplete: data.dailyGoalProgress >= 1.0
        )

        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - Entry

struct ReadingStreakEntry: TimelineEntry {
    let date: Date
    let streakDays: Int
    let todayComplete: Bool
}

// MARK: - Widget View

struct ReadingStreakWidgetView: View {
    var entry: ReadingStreakProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            smallView
        }
    }

    // MARK: - Small Widget

    private var smallView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("Streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(entry.streakDays)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(entry.streakDays > 0 ? .orange : .secondary)

            Text(entry.streakDays == 1 ? "day" : "days")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 4) {
                if entry.todayComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Done today")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                    Text("Read today")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption2)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Circular

    private var circularView: some View {
        VStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(.orange)
            Text("\(entry.streakDays)")
                .font(.system(.title2, design: .rounded, weight: .bold))
        }
    }

    // MARK: - Lock Screen Rectangular

    private var rectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.streakDays) day streak")
                    .font(.headline)

                if entry.todayComplete {
                    Text("Today complete!")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Read to keep streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Lock Screen Inline

    private var inlineView: some View {
        HStack {
            Image(systemName: "flame.fill")
            Text("\(entry.streakDays) day streak")
        }
    }
}

// MARK: - Widget Configuration

struct ReadingStreakWidget: Widget {
    let kind: String = "ReadingStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReadingStreakProvider()) { entry in
            ReadingStreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Reading Streak")
        .description("Track your reading streak")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ReadingStreakWidget()
} timeline: {
    ReadingStreakEntry(
        date: Date(),
        streakDays: 7,
        todayComplete: true
    )
}

#Preview(as: .accessoryCircular) {
    ReadingStreakWidget()
} timeline: {
    ReadingStreakEntry(
        date: Date(),
        streakDays: 14,
        todayComplete: false
    )
}
