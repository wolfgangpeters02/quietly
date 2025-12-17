import SwiftUI

struct StatsCard: View {
    let title: String
    let value: String
    var subtitle: String?
    let icon: String

    @State private var hasAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.quietly.textSecondary)

                Spacer()

                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(iconColor)
                    .symbolEffect(.bounce, value: hasAppeared)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.quietly.textPrimary)
                .contentTransition(.numericText())

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Color.quietly.textSecondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.quietly.shadow, radius: 4, x: 0, y: 2)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                hasAppeared = true
            }
        }
    }

    private var iconColor: Color {
        switch icon {
        case "flame.fill":
            return .orange
        case "checkmark.circle.fill":
            return Color.quietly.success
        default:
            return Color.quietly.accent
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        StatsCard(
            title: "Streak",
            value: "7",
            subtitle: "days",
            icon: "flame.fill"
        )

        StatsCard(
            title: "Library",
            value: "24",
            subtitle: "books",
            icon: "books.vertical.fill"
        )

        StatsCard(
            title: "Completed",
            value: "12",
            subtitle: "books",
            icon: "checkmark.circle.fill"
        )
    }
    .padding()
    .background(Color.quietly.background)
}
