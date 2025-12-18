import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "books.vertical.fill",
            title: "Welcome to Quietly",
            subtitle: "Your personal reading companion",
            description: "Track your reading, take notes, and build lasting reading habits."
        ),
        OnboardingPage(
            icon: "clock.fill",
            title: "Track Your Reading",
            subtitle: "Sessions & Progress",
            description: "Start a reading session, track your time, and see your progress grow with every page."
        ),
        OnboardingPage(
            icon: "note.text",
            title: "Capture Moments",
            subtitle: "Notes",
            description: "Save your thoughts by scanning book pages or typing notes as you read."
        ),
        OnboardingPage(
            icon: "flame.fill",
            title: "Build Your Streak",
            subtitle: "Goals & Habits",
            description: "Set daily reading goals and watch your streak grow. Consistency is key!"
        )
    ]

    var body: some View {
        ZStack {
            Color.quietly.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button - top aligned
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(height: 44)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom section with indicators and button
                VStack(spacing: 24) {
                    // Page indicators - animated capsule style
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.quietly.primary : Color.quietly.primary.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // Action button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                            .font(.headline)
                            .foregroundColor(Color.quietly.primaryForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.quietly.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon with animation
            ZStack {
                Circle()
                    .fill(Color.quietly.primary.opacity(0.08))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(Color.quietly.primary.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color.quietly.primary)
                    .symbolEffect(.pulse.wholeSymbol, options: .repeating, value: isAnimating)
            }

            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.quietly.textPrimary)
                .multilineTextAlignment(.center)

            // Subtitle
            Text(page.subtitle)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.quietly.accent)

            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(Color.quietly.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
