import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
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
                                            viewModel.deleteNote(note, context: modelContext)
                                        }
                                        .listRowBackground(Color.quietly.card)
                                    }
                                } label: {
                                    BookNotesHeader(book: group.book, noteCount: group.noteCount)
                                }
                                .listRowBackground(Color.quietly.card)
                                .tint(Color.quietly.primary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.quietly.background)
                } else if !viewModel.isLoading {
                    EmptyStateView(
                        icon: "note.text",
                        title: "No notes yet",
                        message: "Your notes will appear here"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.quietly.background)
                }
            }
            .background(Color.quietly.background)
            .navigationTitle("Notes")
            .searchable(text: $viewModel.searchText, prompt: "Search notes...")
            .tint(Color.quietly.primary)
            .refreshable {
                viewModel.refresh(context: modelContext)
            }
            .onAppear {
                viewModel.loadData(context: modelContext)
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

    @State private var isExpanded = false

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
                .lineLimit(isExpanded ? nil : 4)

            // Show expand/collapse button if text is long
            if note.content.count > 150 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(.caption)
                        .foregroundColor(Color.quietly.primary)
                }
                .buttonStyle(.plain)
            }
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
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
