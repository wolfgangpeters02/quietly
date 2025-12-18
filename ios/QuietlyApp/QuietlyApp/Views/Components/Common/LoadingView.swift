import SwiftUI

struct LoadingView: View {
    var message: String?

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.quietly.primary)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.quietly.background)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
        }
    }
}

#Preview {
    LoadingView(message: "Loading books...")
}
