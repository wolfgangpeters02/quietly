import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ReadingStatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReadingStatsEntry {
        ReadingStatsEntry(
            date: Date(),
            todayMinutes: 45,
            goalMinutes: 30,
            goalProgress: 1.0,
            booksThisYear: 12
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ReadingStatsEntry) -> Void) {
        let data = WidgetDataReader.getReadingData()
        let entry = ReadingStatsEntry(
            date: Date(),
            todayMinutes: data.todayReadingMinutes,
            goalMinutes: data.dailyGoalMinutes,
            goalProgress: data.dailyGoalProgress,
            booksThisYear: data.booksCompletedThisYear
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReadingStatsEntry>) -> Void) {
        let data = WidgetDataReader.getReadingData()
        let entry = ReadingStatsEntry(
            date: Date(),
            todayMinutes: data.todayReadingMinutes,
            goalMinutes: data.dailyGoalMinutes,
            goalProgress: data.dailyGoalProgress,
            booksThisYear: data.booksCompletedThisYear
        )

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry

struct ReadingStatsEntry: TimelineEntry {
    let date: Date
    let todayMinutes: Int
    let goalMinutes: Int
    let goalProgress: Double
    let booksThisYear: Int
}

// MARK: - Widget View

struct ReadingStatsWidgetView: View {
    var entry: ReadingStatsProvider.Entry
    @Environment(\.widgetFamily) var family

    private var formattedTime: String {
        let hours = entry.todayMinutes / 60
        let minutes = entry.todayMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        default:
            smallView
        }
    }

    // MARK: - Small Widget

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(formattedTime)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()

            if entry.goalMinutes > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: entry.goalProgress)
                        .tint(entry.goalProgress >= 1.0 ? .green : .accentColor)

                    HStack {
                        Text("Goal: \(entry.goalMinutes)m")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if entry.goalProgress >= 1.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumView: some View {
        HStack(spacing: 20) {
            // Today's reading
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text("Today")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                Text(formattedTime)
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                if entry.goalMinutes > 0 {
                    ProgressView(value: entry.goalProgress)
                        .tint(entry.goalProgress >= 1.0 ? .green : .accentColor)

                    HStack {
                        Text("\(entry.goalMinutes)m goal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if entry.goalProgress >= 1.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Books this year
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "books.vertical.fill")
                        .font(.caption)
                    Text("This Year")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                Text("\(entry.booksThisYear)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("books finished")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Circular

    private var circularView: some View {
        Gauge(value: min(entry.goalProgress, 1.0)) {
            Image(systemName: "clock.fill")
        } currentValueLabel: {
            Text("\(entry.todayMinutes)")
                .font(.system(.caption, design: .rounded))
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }

    // MARK: - Lock Screen Rectangular

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "clock.fill")
                Text("Today: \(formattedTime)")
            }
            .font(.headline)

            if entry.goalMinutes > 0 {
                ProgressView(value: entry.goalProgress)

                Text("\(Int(entry.goalProgress * 100))% of \(entry.goalMinutes)m goal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Widget Configuration

struct ReadingStatsWidget: Widget {
    let kind: String = "ReadingStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReadingStatsProvider()) { entry in
            ReadingStatsWidgetView(entry: entry)
        }
        .configurationDisplayName("Reading Stats")
        .description("Track today's reading time and yearly progress")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ReadingStatsWidget()
} timeline: {
    ReadingStatsEntry(
        date: Date(),
        todayMinutes: 45,
        goalMinutes: 30,
        goalProgress: 1.0,
        booksThisYear: 12
    )
}

#Preview(as: .systemMedium) {
    ReadingStatsWidget()
} timeline: {
    ReadingStatsEntry(
        date: Date(),
        todayMinutes: 25,
        goalMinutes: 30,
        goalProgress: 0.83,
        booksThisYear: 8
    )
}
