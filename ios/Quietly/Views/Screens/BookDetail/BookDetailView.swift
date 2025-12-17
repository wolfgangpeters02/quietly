import SwiftUI

struct BookDetailView: View {
    @StateObject private var viewModel: BookDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showReadingSession = false

    init(userBook: UserBook) {
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(userBook: userBook))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Book header
                bookHeader

                // Actions
                actionButtons

                // Stats
                if let stats = viewModel.bookStats, stats.totalSessions > 0 {
                    statsSection(stats)
                }

                // Notes section
                notesSection
            }
            .padding()
        }
        .background(Color.quietly.background)
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(ReadingStatus.allCases) { status in
                        Button {
                            Task { await viewModel.updateStatus(status) }
                        } label: {
                            Label(status.displayName, systemImage: status.iconName)
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        viewModel.showDeleteConfirmation = true
                    } label: {
                        Label("Remove from Library", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showReadingSession) {
            NavigationStack {
                ReadingSessionView(userBook: viewModel.userBook)
            }
        }
        .alert("Remove Book", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                Task {
                    if await viewModel.removeFromLibrary() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to remove this book from your library?")
        }
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Book Header
    private var bookHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            // Cover
            AsyncImage(url: URL(string: viewModel.book?.coverUrl ?? "")) { phase in
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
                                .font(.title)
                                .foregroundColor(Color.quietly.mutedForeground)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 180)
            .cornerRadius(8)
            .shadow(color: Color.quietly.shadowBook, radius: 8, x: 0, y: 4)

            // Info
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.book?.title ?? "Unknown")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.quietly.textPrimary)

                if let author = viewModel.book?.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                }

                StatusBadge(status: viewModel.userBook.status)

                if viewModel.userBook.status == .reading {
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressBar(progress: viewModel.progress, height: 6)
                        Text(viewModel.progressText)
                            .font(.caption)
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                }

                // Rating
                if let rating = viewModel.userBook.rating, rating > 0 {
                    StarRatingDisplay(rating: rating)
                }
            }

            Spacer()
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            if viewModel.userBook.status == .reading {
                Button {
                    showReadingSession = true
                } label: {
                    Label("Continue Reading", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.accent)
            } else if viewModel.userBook.status == .wantToRead {
                Button {
                    Task {
                        await viewModel.updateStatus(.reading)
                        showReadingSession = true
                    }
                } label: {
                    Label("Start Reading", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.primary)
            }

            // Rate button
            Menu {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        Task { await viewModel.updateRating(rating) }
                    } label: {
                        Label(
                            String(repeating: "★", count: rating),
                            systemImage: "star.fill"
                        )
                    }
                }
            } label: {
                Image(systemName: "star")
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Stats Section
    private func statsSection(_ stats: BookReadingStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reading Statistics")
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)

            HStack(spacing: 16) {
                StatItem(title: "Sessions", value: "\(stats.totalSessions)")
                StatItem(title: "Time", value: stats.formattedTotalTime)
                StatItem(title: "Pages", value: "\(stats.totalPagesRead)")
                StatItem(title: "Speed", value: stats.formattedSpeed)
            }
        }
        .cardStyle()
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Notes & Quotes")
                    .font(.headline)
                    .foregroundColor(Color.quietly.textPrimary)

                Spacer()

                Button {
                    viewModel.showScanText = true
                } label: {
                    Label("Scan", systemImage: "camera")
                        .font(.subheadline)
                }
            }

            // Add note form
            VStack(spacing: 12) {
                TextEditor(text: $viewModel.noteContent)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color.quietly.secondary.opacity(0.3))
                    .cornerRadius(8)

                HStack {
                    Picker("Type", selection: $viewModel.noteType) {
                        ForEach(NoteType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)

                    TextField("Page", text: $viewModel.notePageNumber)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)

                    Spacer()

                    Button("Save") {
                        Task { await viewModel.addNote() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.quietly.primary)
                    .disabled(viewModel.noteContent.trimmed.isEmpty)
                }
            }

            // Notes list
            if viewModel.notes.isEmpty {
                Text("No notes yet")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.notes) { note in
                    NoteCard(note: note) {
                        Task { await viewModel.deleteNote(note) }
                    }
                }
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundColor(Color.quietly.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        BookDetailView(
            userBook: UserBook(
                id: UUID(),
                userId: UUID(),
                bookId: UUID(),
                status: .reading,
                currentPage: 45,
                rating: 4,
                startedAt: Date(),
                completedAt: nil,
                createdAt: Date(),
                updatedAt: Date(),
                book: Book(
                    title: "The Great Gatsby",
                    author: "F. Scott Fitzgerald",
                    pageCount: 180
                )
            )
        )
    }
}
