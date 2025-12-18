import SwiftUI

struct BookCard: View {
    let userBook: UserBook
    var showProgress: Bool = true
    var onContinueReading: (() -> Void)?
    var onStatusChange: ((ReadingStatus) -> Void)?
    var onDelete: (() -> Void)?

    private var book: Book? { userBook.book }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover image with modern corners
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
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 14,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 14
                    )
                )

                // Floating status badge
                StatusBadge(status: userBook.status)
                    .padding(8)
            }

            // Book info
            VStack(alignment: .leading, spacing: 8) {
                Text(book?.title ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.quietly.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)

                if let author = book?.author {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(Color.quietly.textSecondary)
                        .lineLimit(1)
                }

                if showProgress && userBook.status == .reading {
                    ProgressView(value: userBook.progress)
                        .tint(Color.quietly.accent)
                }
            }
            .padding(12)
        }
        .background(Color.quietly.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.quietly.shadowSubtle, radius: 2, x: 0, y: 1)
        .shadow(color: Color.quietly.shadowBook, radius: 6, x: 0, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contextMenu {
            bookContextMenu
        }
    }

    // MARK: - Context Menu
    @ViewBuilder
    private var bookContextMenu: some View {
        // Reading actions based on status
        if userBook.status != .reading {
            Button {
                HapticService.shared.selectionChanged()
                onStatusChange?(.reading)
            } label: {
                Label("Start Reading", systemImage: "book.fill")
            }
        } else if let onContinue = onContinueReading {
            Button {
                HapticService.shared.buttonTap()
                onContinue()
            } label: {
                Label("Continue Reading", systemImage: "play.fill")
            }
        }

        Divider()

        // Status change menu
        Menu {
            ForEach(ReadingStatus.allCases, id: \.self) { status in
                if status != userBook.status {
                    Button {
                        HapticService.shared.selectionChanged()
                        onStatusChange?(status)
                    } label: {
                        Label(status.displayName, systemImage: status.iconName)
                    }
                }
            }
        } label: {
            Label("Change Status", systemImage: "arrow.triangle.2.circlepath")
        }

        Divider()

        // Delete action
        Button(role: .destructive) {
            HapticService.shared.deleted()
            onDelete?()
        } label: {
            Label("Remove from Library", systemImage: "trash")
        }
    }

    @State private var bookIconAnimating = false

    private var placeholderCover: some View {
        Rectangle()
            .fill(Color.quietly.secondary)
            .aspectRatio(2/3, contentMode: .fit)
            .overlay(
                Image(systemName: "book.closed")
                    .font(.system(size: 32))
                    .foregroundColor(Color.quietly.mutedForeground)
                    .symbolEffect(.pulse.byLayer, options: .repeating.speed(0.3), value: bookIconAnimating)
                    .onAppear { bookIconAnimating = true }
            )
    }
}

struct StatusBadge: View {
    let status: ReadingStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(Capsule())
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

    private var foregroundColor: Color {
        switch status {
        case .reading:
            return Color.quietly.accentForeground
        case .completed:
            return Color.quietly.accentForeground
        case .wantToRead:
            return Color.quietly.primaryForeground
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
        book: sampleBook,
        status: .reading,
        currentPage: 45,
        startedAt: Date()
    )

    BookCard(userBook: sampleUserBook) {
        print("Continue reading")
    }
    .frame(width: 160)
    .padding()
    .background(Color.quietly.background)
}
