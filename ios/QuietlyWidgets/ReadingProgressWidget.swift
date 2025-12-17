import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ReadingProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> ReadingProgressEntry {
        ReadingProgressEntry(
            date: Date(),
            bookTitle: "The Great Gatsby",
            bookAuthor: "F. Scott Fitzgerald",
            progress: 0.45,
            coverUrl: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ReadingProgressEntry) -> Void) {
        let data = WidgetDataReader.getReadingData()
        let entry = ReadingProgressEntry(
            date: Date(),
            bookTitle: data.currentBookTitle,
            bookAuthor: data.currentBookAuthor,
            progress: data.currentBookProgress,
            coverUrl: data.currentBookCoverUrl
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ReadingProgressEntry>) -> Void) {
        let data = WidgetDataReader.getReadingData()
        let entry = ReadingProgressEntry(
            date: Date(),
            bookTitle: data.currentBookTitle,
            bookAuthor: data.currentBookAuthor,
            progress: data.currentBookProgress,
            coverUrl: data.currentBookCoverUrl
        )

        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry

struct ReadingProgressEntry: TimelineEntry {
    let date: Date
    let bookTitle: String?
    let bookAuthor: String?
    let progress: Double
    let coverUrl: String?
}

// MARK: - Widget View

struct ReadingProgressWidgetView: View {
    var entry: ReadingProgressProvider.Entry
    @Environment(\.widgetFamily) var family

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
        case .accessoryInline:
            inlineView
        default:
            smallView
        }
    }

    // MARK: - Small Widget

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Reading")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let title = entry.bookTitle {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                if let author = entry.bookAuthor {
                    Text(author)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                ProgressView(value: entry.progress)
                    .tint(.accentColor)

                Text("\(Int(entry.progress * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Spacer()
                Text("No book selected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Medium Widget

    private var mediumView: some View {
        HStack(spacing: 16) {
            // Book cover placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .frame(width: 60, height: 90)
                .overlay {
                    Image(systemName: "book.closed.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "book.fill")
                        .font(.caption)
                    Text("Currently Reading")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                if let title = entry.bookTitle {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)

                    if let author = entry.bookAuthor {
                        Text(author)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack {
                        ProgressView(value: entry.progress)
                            .tint(.accentColor)
                        Text("\(Int(entry.progress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Spacer()
                    Text("Tap to start reading")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }

            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    // MARK: - Lock Screen Circular

    private var circularView: some View {
        Gauge(value: entry.progress) {
            Image(systemName: "book.fill")
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }

    // MARK: - Lock Screen Rectangular

    private var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "book.fill")
                Text(entry.bookTitle ?? "No book")
                    .lineLimit(1)
            }
            .font(.headline)

            ProgressView(value: entry.progress)

            Text("\(Int(entry.progress * 100))% complete")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Lock Screen Inline

    private var inlineView: some View {
        HStack {
            Image(systemName: "book.fill")
            if let title = entry.bookTitle {
                Text("\(title) - \(Int(entry.progress * 100))%")
            } else {
                Text("No book selected")
            }
        }
    }
}

// MARK: - Widget Configuration

struct ReadingProgressWidget: Widget {
    let kind: String = "ReadingProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ReadingProgressProvider()) { entry in
            ReadingProgressWidgetView(entry: entry)
        }
        .configurationDisplayName("Reading Progress")
        .description("Track your current book progress")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ReadingProgressWidget()
} timeline: {
    ReadingProgressEntry(
        date: Date(),
        bookTitle: "The Great Gatsby",
        bookAuthor: "F. Scott Fitzgerald",
        progress: 0.45,
        coverUrl: nil
    )
}

#Preview(as: .systemMedium) {
    ReadingProgressWidget()
} timeline: {
    ReadingProgressEntry(
        date: Date(),
        bookTitle: "The Great Gatsby",
        bookAuthor: "F. Scott Fitzgerald",
        progress: 0.45,
        coverUrl: nil
    )
}

#Preview(as: .accessoryCircular) {
    ReadingProgressWidget()
} timeline: {
    ReadingProgressEntry(
        date: Date(),
        bookTitle: "The Great Gatsby",
        bookAuthor: "F. Scott Fitzgerald",
        progress: 0.45,
        coverUrl: nil
    )
}
