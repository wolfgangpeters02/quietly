import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasNotes {
                    List {
                        ForEach(viewModel.filteredGroupedNotes) { group in
                            Section {
                                DisclosureGroup {
                                    ForEach(group.notes) { note in
                                        NoteRow(note: note) {
                                            Task { await viewModel.deleteNote(note) }
                                        }
                                    }
                                } label: {
                                    BookNotesHeader(book: group.book, noteCount: group.noteCount)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                } else if !viewModel.isLoading {
                    EmptyStateView(
                        icon: "note.text",
                        title: "No notes yet",
                        message: "Your notes and quotes will appear here"
                    )
                }
            }
            .background(Color.quietly.background)
            .navigationTitle("Notes")
            .searchable(text: $viewModel.searchText, prompt: "Search notes...")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
            }
            .overlay {
                if viewModel.isLoading && !viewModel.hasNotes {
                    LoadingView(message: "Loading notes...")
                }
            }
        }
    }
}

struct BookNotesHeader: View {
    let book: Book
    let noteCount: Int

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: book.coverUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    Rectangle()
                        .fill(Color.quietly.secondary)
                        .overlay(
                            Image(systemName: "book.closed")
                                .foregroundColor(Color.quietly.mutedForeground)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 40, height: 60)
            .cornerRadius(4)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.quietly.textPrimary)
                    .lineLimit(1)

                if let author = book.author {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(Color.quietly.textSecondary)
                        .lineLimit(1)
                }

                Text("\(noteCount) \(noteCount == 1 ? "note" : "notes")")
                    .font(.caption2)
                    .foregroundColor(Color.quietly.textMuted)
            }

            Spacer()
        }
    }
}

struct NoteRow: View {
    let note: Note
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            }

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(Color.quietly.textPrimary)
                .lineLimit(4)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NotesView()
}
