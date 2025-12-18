import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
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
                HStack(spacing: 8) {
                    // Share button
                    if let book = viewModel.book {
                        ShareLink(
                            item: "I'm reading \"\(book.title)\"" + (book.author.map { " by \($0)" } ?? "") + " 📚",
                            subject: Text(book.title),
                            message: Text("Check out this book!")
                        ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }

                    // More options menu
                    Menu {
                        ForEach(ReadingStatus.allCases) { status in
                            Button {
                                viewModel.updateStatus(status, context: modelContext)
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
        }
        .sheet(isPresented: $showReadingSession) {
            NavigationStack {
                ReadingSessionView(userBook: viewModel.userBook)
            }
        }
        .sheet(isPresented: $viewModel.showScanText) {
            ScanTextSheet { scannedText in
                viewModel.addNoteFromScan(scannedText, context: modelContext)
            }
        }
        .confirmationDialog(
            "Remove Book",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove from Library", role: .destructive) {
                if viewModel.removeFromLibrary(context: modelContext) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove \"\(viewModel.book?.title ?? "this book")\" from your library and all associated notes and reading sessions.")
        }
        .onAppear {
            viewModel.loadData(context: modelContext)
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
                    viewModel.updateStatus(.reading, context: modelContext)
                    showReadingSession = true
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
                        viewModel.updateRating(rating, context: modelContext)
                    } label: {
                        Label(
                            String(repeating: "★", count: rating),
                            systemImage: "star.fill"
                        )
                    }
                }
            } label: {
                Image(systemName: "star")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.quietly.secondary)
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
                Text("Notes")
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
                        viewModel.addNote(context: modelContext)
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
                        viewModel.deleteNote(note, context: modelContext)
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
                book: Book(
                    title: "The Great Gatsby",
                    author: "F. Scott Fitzgerald",
                    pageCount: 180
                ),
                status: .reading,
                currentPage: 45,
                rating: 4,
                startedAt: Date()
            )
        )
    }
    .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
