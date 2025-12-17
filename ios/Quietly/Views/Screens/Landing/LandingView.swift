import SwiftUI

struct LandingView: View {
    @State private var showAuth = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 48) {
                    // Hero section
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.quietly.primary)

                        Text(AppConstants.App.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.quietly.textPrimary)

                        Text(AppConstants.App.tagline)
                            .font(.title3)
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                    .padding(.top, 60)

                    // Features
                    VStack(spacing: 24) {
                        FeatureRow(
                            icon: "timer",
                            title: "Track Reading Time",
                            description: "Time your reading sessions with pause and resume support"
                        )

                        FeatureRow(
                            icon: "target",
                            title: "Set Goals",
                            description: "Daily, weekly, or yearly reading goals to keep you motivated"
                        )

                        FeatureRow(
                            icon: "note.text",
                            title: "Save Notes",
                            description: "Capture your thoughts and favorite quotes as you read"
                        )

                        FeatureRow(
                            icon: "flame.fill",
                            title: "Build Streaks",
                            description: "Track your reading streak and celebrate consistency"
                        )
                    }
                    .padding(.horizontal)

                    // CTA
                    VStack(spacing: 16) {
                        Button {
                            showAuth = true
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.quietly.primary)

                        Text("Free to use. No credit card required.")
                            .font(.caption)
                            .foregroundColor(Color.quietly.textMuted)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.quietly.background)
            .fullScreenCover(isPresented: $showAuth) {
                AuthView()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color.quietly.accent)
                .frame(width: 44, height: 44)
                .background(Color.quietly.accent.opacity(0.15))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.quietly.textPrimary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(16)
    }
}

#Preview {
    LandingView()
}
