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
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
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
        .background(Color.quietly.primary.opacity(0.15))
        .foregroundColor(Color.quietly.primary)
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 12) {
        NoteCard(
            note: Note(
                content: "This is a sample note about the book. It contains my thoughts and observations.",
                noteType: .note,
                pageNumber: 42
            )
        ) {
            print("Delete tapped")
        }

        NoteCard(
            note: Note(
                content: "In my younger and more vulnerable years my father gave me some advice that I've been turning over in my mind ever since.",
                noteType: .note,
                pageNumber: 1
            )
        )
    }
    .padding()
    .background(Color.quietly.background)
}
