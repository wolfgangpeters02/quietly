import SwiftUI
import SwiftData
import Charts

struct ReadingHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ReadingHistoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time range picker
                    Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                        ForEach(ReadingHistoryViewModel.TimeRange.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Stats overview
                    statsSection

                    // Weekly chart
                    if viewModel.selectedTimeRange == .week {
                        weeklyChartSection
                    }

                    // Sessions list
                    sessionsSection
                }
                .padding(.vertical)
            }
            .background(Color.quietly.background)
            .navigationTitle("Reading History")
            .refreshable {
                viewModel.refresh(context: modelContext)
            }
            .onAppear {
                viewModel.loadData(context: modelContext)
            }
            .overlay {
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    LoadingView(message: "Loading history...")
                }
            }
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatBox(
                    title: "Total Time",
                    value: formatMinutes(viewModel.totalMinutes),
                    icon: "clock.fill",
                    color: Color.quietly.accent
                )

                StatBox(
                    title: "Sessions",
                    value: "\(viewModel.totalSessions)",
                    icon: "book.fill",
                    color: Color.quietly.primary
                )
            }

            HStack(spacing: 12) {
                StatBox(
                    title: "Pages Read",
                    value: "\(viewModel.totalPages)",
                    icon: "doc.text.fill",
                    color: Color.quietly.success
                )

                StatBox(
                    title: "Avg Session",
                    value: "\(viewModel.averageSessionLength) min",
                    icon: "chart.bar.fill",
                    color: Color.quietly.primary
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Weekly Chart Section
    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)

            Chart(viewModel.weeklyData, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Minutes", item.minutes)
                )
                .foregroundStyle(Color.quietly.accent.gradient)
                .cornerRadius(4)
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .padding(.horizontal)
    }

    // MARK: - Sessions Section
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sessions")
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)
                .padding(.horizontal)

            if viewModel.groupedSessions.isEmpty {
                EmptyStateView(
                    icon: "clock.badge.questionmark",
                    title: "No reading sessions",
                    message: "Start a reading session to track your progress"
                )
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.groupedSessions, id: \.date) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            // Date header
                            Text(formatDate(group.date))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.quietly.textSecondary)
                                .padding(.horizontal)

                            // Sessions for this date
                            ForEach(group.sessions) { session in
                                SessionCard(session: session) {
                                    viewModel.deleteSession(session, context: modelContext)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes) min"
    }

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    @State private var hasAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .symbolEffect(.bounce, value: hasAppeared)

                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.quietly.textPrimary)
                .contentTransition(.numericText())

            Text(title)
                .font(.caption)
                .foregroundColor(Color.quietly.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                hasAppeared = true
            }
        }
    }
}

// MARK: - Session Card
struct SessionCard: View {
    let session: ReadingSession
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Book cover
            if let book = session.book {
                AsyncImage(url: URL(string: book.coverUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color.quietly.secondary)
                            .overlay(
                                Image(systemName: "book.closed")
                                    .foregroundColor(Color.quietly.mutedForeground)
                            )
                    }
                }
                .frame(width: 50, height: 70)
                .cornerRadius(6)
            }

            // Session info
            VStack(alignment: .leading, spacing: 4) {
                if let book = session.book {
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.quietly.textPrimary)
                        .lineLimit(1)
                }

                Text(formatTime(session.startedAt))
                    .font(.caption)
                    .foregroundColor(Color.quietly.textSecondary)

                HStack(spacing: 12) {
                    Label(session.formattedDuration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(Color.quietly.accent)

                    if let pages = session.pagesRead, pages > 0 {
                        Label("\(pages) pages", systemImage: "doc.text")
                            .font(.caption)
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Session", systemImage: "trash")
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ReadingHistoryView()
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
