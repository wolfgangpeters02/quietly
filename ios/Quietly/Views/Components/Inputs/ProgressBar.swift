import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var backgroundColor: Color = Color.quietly.secondary
    var foregroundColor: Color = Color.quietly.accent
    var showPercentage: Bool = false
    var animated: Bool = true

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(backgroundColor)
                        .frame(height: height)

                    // Progress
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(foregroundColor)
                        .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1)), height: height)
                        .animation(animated ? .easeInOut(duration: 0.3) : nil, value: progress)
                }
            }
            .frame(height: height)

            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(Color.quietly.textSecondary)
            }
        }
    }
}

struct CircularProgressBar: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 60
    var backgroundColor: Color = Color.quietly.secondary
    var foregroundColor: Color = Color.quietly.accent
    var showPercentage: Bool = true

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.quietly.textPrimary)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 32) {
        ProgressBar(progress: 0.65, showPercentage: true)
            .padding(.horizontal)

        ProgressBar(progress: 0.3, height: 12, foregroundColor: Color.quietly.primary)
            .padding(.horizontal)

        HStack(spacing: 24) {
            CircularProgressBar(progress: 0.75)
            CircularProgressBar(progress: 0.5, foregroundColor: Color.quietly.primary)
            CircularProgressBar(progress: 1.0, foregroundColor: Color.quietly.success)
        }
    }
    .padding()
}
