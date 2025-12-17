import SwiftUI

struct StatsCard: View {
    let title: String
    let value: String
    var subtitle: String?
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.quietly.textSecondary)

                Spacer()

                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(Color.quietly.accent)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.quietly.textPrimary)

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
