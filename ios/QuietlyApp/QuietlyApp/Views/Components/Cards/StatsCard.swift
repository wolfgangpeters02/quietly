import SwiftUI

// MARK: - Stats Row (Single container for all stats)
struct StatsRow: View {
    let stats: [StatItem]

    struct StatItem: Identifiable {
        let id = UUID()
        let title: String
        let value: String
        let subtitle: String?
        let icon: String
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                StatCell(
                    title: stat.title,
                    value: stat.value,
                    subtitle: stat.subtitle,
                    icon: stat.icon
                )

                if index < stats.count - 1 {
                    Divider()
                        .frame(height: 40)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color.quietly.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Individual Stat Cell (not interactive)
struct StatCell: View {
    let title: String
    let value: String
    var subtitle: String?
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            // Icon and label
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(Color.quietly.textMuted)

                Text(title)
                    .font(.caption2)
                    .foregroundColor(Color.quietly.textMuted)
            }

            // Value
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(Color.quietly.textPrimary)
                .contentTransition(.numericText())

            // Subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Color.quietly.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Legacy StatsCard (for backwards compatibility)
struct StatsCard: View {
    let title: String
    let value: String
    var subtitle: String?
    let icon: String

    var body: some View {
        StatCell(
            title: title,
            value: value,
            subtitle: subtitle,
            icon: icon
        )
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(Color.quietly.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 20) {
        // New unified stats row
        StatsRow(stats: [
            .init(title: "Streak", value: "7", subtitle: "days", icon: "flame.fill"),
            .init(title: "Library", value: "24", subtitle: "books", icon: "books.vertical.fill"),
            .init(title: "Completed", value: "12", subtitle: "this year", icon: "checkmark.circle.fill")
        ])

        // Legacy individual cards (for reference)
        HStack(spacing: 12) {
            StatsCard(title: "Streak", value: "7", subtitle: "days", icon: "flame.fill")
            StatsCard(title: "Library", value: "24", subtitle: "books", icon: "books.vertical.fill")
            StatsCard(title: "Completed", value: "12", subtitle: "this year", icon: "checkmark.circle.fill")
        }
    }
    .padding()
    .background(Color.quietly.background)
}
