import SwiftUI

struct StarRating: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 24
    var spacing: CGFloat = 4
    var interactive: Bool = true

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(index <= rating ? Color.quietly.accent : Color.quietly.mutedForeground)
                    .onTapGesture {
                        if interactive {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if rating == index {
                                    rating = 0
                                } else {
                                    rating = index
                                }
                            }
                        }
                    }
            }
        }
    }
}

struct StarRatingDisplay: View {
    let rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 16
    var spacing: CGFloat = 2

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(index <= rating ? Color.quietly.accent : Color.quietly.mutedForeground)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        StarRating(rating: .constant(3))

        StarRating(rating: .constant(5), size: 32)

        StarRatingDisplay(rating: 4)

        StarRatingDisplay(rating: 2, size: 12)
    }
    .padding()
}
