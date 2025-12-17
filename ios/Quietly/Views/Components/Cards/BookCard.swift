import SwiftUI

struct BookCard: View {
    let userBook: UserBook
    var showProgress: Bool = true
    var onContinueReading: (() -> Void)?

    private var book: Book? { userBook.book }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: book?.coverUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderCover
                    case .empty:
                        placeholderCover
                            .overlay(ProgressView().tint(Color.quietly.primary))
                    @unknown default:
                        placeholderCover
                    }
                }
                .aspectRatio(2/3, contentMode: .fit)
                .clipped()

                // Status badge
                StatusBadge(status: userBook.status)
                    .padding(8)
            }

            // Book info
            VStack(alignment: .leading, spacing: 6) {
                Text(book?.title ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.quietly.textPrimary)
                    .lineLimit(2)

                if let author = book?.author {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(Color.quietly.textSecondary)
                        .lineLimit(1)
                }

                if showProgress && userBook.status == .reading {
                    VStack(spacing: 8) {
                        ProgressView(value: userBook.progress)
                            .tint(Color.quietly.accent)

                        if let onContinue = onContinueReading {
                            Button(action: onContinue) {
                                Label("Continue", systemImage: "play.fill")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.quietly.accent)
                            .controlSize(.small)
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.quietly.shadowBook, radius: 4, x: 0, y: 4)
    }

    private var placeholderCover: some View {
        Rectangle()
            .fill(Color.quietly.secondary)
            .aspectRatio(2/3, contentMode: .fit)
            .overlay(
                Image(systemName: "book.closed")
                    .font(.system(size: 32))
                    .foregroundColor(Color.quietly.mutedForeground)
            )
    }
}

struct StatusBadge: View {
    let status: ReadingStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private var backgroundColor: Color {
        switch status {
        case .reading:
            return Color.quietly.accent
        case .completed:
            return Color.quietly.success
        case .wantToRead:
            return Color.quietly.primary
        }
    }
}

#Preview {
    let sampleBook = Book(
        title: "The Great Gatsby",
        author: "F. Scott Fitzgerald",
        coverUrl: nil,
        pageCount: 180
    )

    let sampleUserBook = UserBook(
        id: UUID(),
        userId: UUID(),
        bookId: sampleBook.id,
        status: .reading,
        currentPage: 45,
        rating: nil,
        startedAt: Date(),
        completedAt: nil,
        createdAt: Date(),
        updatedAt: Date(),
        book: sampleBook
    )

    BookCard(userBook: sampleUserBook) {
        print("Continue reading")
    }
    .frame(width: 160)
    .padding()
    .background(Color.quietly.background)
}
