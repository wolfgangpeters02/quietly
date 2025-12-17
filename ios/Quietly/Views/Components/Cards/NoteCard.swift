import SwiftUI

struct NoteCard: View {
    let note: Note
    var onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                NoteTypeBadge(type: note.noteType)

                if let pageLabel = note.pageLabel {
                    Text(pageLabel)
                        .font(.caption)
                        .foregroundColor(Color.quietly.textSecondary)
                }

                Spacer()

                Text(note.createdAt.relativeFormatted)
                    .font(.caption2)
                    .foregroundColor(Color.quietly.textMuted)

                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(Color.quietly.destructive)
                    }
                }
            }

            // Content
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(Color.quietly.textPrimary)
                .lineLimit(nil)

            // Quote styling
            if note.noteType == .quote {
                Rectangle()
                    .fill(Color.quietly.accent.opacity(0.3))
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
            }
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .stroke(
                    note.noteType == .quote ? Color.quietly.accent.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

struct NoteTypeBadge: View {
    let type: NoteType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.iconName)
                .font(.caption2)

            Text(type.displayName)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor.opacity(0.15))
        .foregroundColor(backgroundColor)
        .cornerRadius(6)
    }

    private var backgroundColor: Color {
        switch type {
        case .note:
            return Color.quietly.primary
        case .quote:
            return Color.quietly.accent
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        NoteCard(
            note: Note(
                id: UUID(),
                userId: UUID(),
                bookId: UUID(),
                content: "This is a sample note about the book. It contains my thoughts and observations.",
                noteType: .note,
                pageNumber: 42,
                createdAt: Date(),
                updatedAt: Date()
            )
        ) {
            print("Delete tapped")
        }

        NoteCard(
            note: Note(
                id: UUID(),
                userId: UUID(),
                bookId: UUID(),
                content: "\"In my younger and more vulnerable years my father gave me some advice that I've been turning over in my mind ever since.\"",
                noteType: .quote,
                pageNumber: 1,
                createdAt: Date().adding(days: -1),
                updatedAt: Date()
            )
        )
    }
    .padding()
    .background(Color.quietly.background)
}
