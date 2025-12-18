import SwiftUI
import SwiftData
import TipKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedBook: UserBook?
    @State private var bookToDelete: UserBook?

    // Tips
    private let addFirstBookTip = AddFirstBookTip()
    private let longPressTip = LongPressTip()
    private let startReadingTip = StartReadingTip()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Currently reading - Quick access
                    if let currentBook = viewModel.currentlyReadingBook {
                        CurrentlyReadingCard(
                            userBook: currentBook,
                            onContinue: {
                                selectedBook = currentBook
                            }
                        )
                        .padding(.horizontal)
                    }

                    // Stats row
                    StatsRow(stats: [
                        .init(
                            title: "Streak",
                            value: "\(viewModel.stats.readingStreak)",
                            subtitle: viewModel.stats.streakLabel,
                            icon: "flame.fill"
                        ),
                        .init(
                            title: "Library",
                            value: "\(viewModel.stats.totalBooks)",
                            subtitle: "books",
                            icon: "books.vertical.fill"
                        ),
                        .init(
                            title: "Completed",
                            value: "\(viewModel.stats.booksCompleted)",
                            subtitle: "this year",
                            icon: "checkmark.circle.fill"
                        )
                    ])
                    .padding(.horizontal)

                    // Goal progress section
                    if !viewModel.goalProgress.isEmpty {
                        GoalProgressSection(progressList: viewModel.goalProgress)
                            .padding(.horizontal)
                    }

                    // Tips
                    if viewModel.userBooks.isEmpty {
                        TipView(addFirstBookTip)
                            .padding(.horizontal)
                    } else if viewModel.readingBooks.count >= 1 {
                        TipView(startReadingTip)
                            .padding(.horizontal)
                    }

                    if viewModel.userBooks.count >= 2 {
                        TipView(longPressTip)
                            .padding(.horizontal)
                    }

                    // Tab picker
                    Picker("Filter", selection: $viewModel.selectedTab) {
                        Text("Reading (\(viewModel.countForTab(.reading)))")
                            .tag(ReadingStatus?.some(.reading))
                        Text("Next (\(viewModel.countForTab(.wantToRead)))")
                            .tag(ReadingStatus?.some(.wantToRead))
                        Text("Done (\(viewModel.countForTab(.completed)))")
                            .tag(ReadingStatus?.some(.completed))
                        Text("All (\(viewModel.countForTab(nil)))")
                            .tag(ReadingStatus?.none)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Book grid
                    if viewModel.filteredBooks.isEmpty && !viewModel.isLoading {
                        EmptyStateView(
                            icon: "books.vertical",
                            title: emptyStateTitle,
                            message: emptyStateMessage,
                            actionTitle: "Add Book"
                        ) {
                            viewModel.showAddBook = true
                        }
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(viewModel.filteredBooks) { userBook in
                                NavigationLink(value: userBook) {
                                    BookCard(
                                        userBook: userBook,
                                        onContinueReading: {
                                            selectedBook = userBook
                                        },
                                        onStatusChange: { status in
                                            viewModel.updateBookStatus(userBook, to: status, context: modelContext)
                                        },
                                        onDelete: {
                                            bookToDelete = userBook
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            // Add book card
                            AddBookCard {
                                viewModel.showAddBook = true
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.quietly.background.ignoresSafeArea())
            .navigationTitle(AppConstants.App.name)
            .navigationDestination(for: UserBook.self) { userBook in
                BookDetailView(userBook: userBook)
            }
            .sheet(isPresented: $viewModel.showAddBook) {
                AddBookSheet {
                    viewModel.refresh(context: modelContext)
                }
            }
            .sheet(item: $selectedBook) { userBook in
                NavigationStack {
                    ReadingSessionView(userBook: userBook)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search your library")
            .refreshable {
                viewModel.refresh(context: modelContext)
            }
            .onAppear {
                viewModel.loadData(context: modelContext)
            }
            .onChange(of: viewModel.userBooks.count) { _, newCount in
                // Update tip parameters
                ScanBookTip.hasAddedBook = newCount > 0
                StartReadingTip.hasAddedBook = newCount > 0
                LongPressTip.bookCount = newCount
            }
            .confirmationDialog(
                "Remove Book",
                isPresented: Binding(
                    get: { bookToDelete != nil },
                    set: { if !$0 { bookToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Remove from Library", role: .destructive) {
                    if let book = bookToDelete {
                        viewModel.removeBook(book, context: modelContext)
                        bookToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    bookToDelete = nil
                }
            } message: {
                Text("This will remove \"\(bookToDelete?.book?.title ?? "this book")\" from your library.")
            }
            .overlay {
                if viewModel.isLoading && viewModel.userBooks.isEmpty {
                    LoadingView(message: "Loading your library...")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .triggerReadingSession)) { _ in
                // Open reading session for currently reading book
                if let currentBook = viewModel.currentlyReadingBook {
                    selectedBook = currentBook
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .showAddBook)) { _ in
                viewModel.showAddBook = true
            }
        }
    }

    private var emptyStateTitle: String {
        switch viewModel.selectedTab {
        case .reading:
            return "Nothing currently reading"
        case .wantToRead:
            return "No books in queue"
        case .completed:
            return "No completed books yet"
        case .none:
            return "Your library is empty"
        }
    }

    private var emptyStateMessage: String {
        switch viewModel.selectedTab {
        case .reading:
            return "Start reading a book from your queue"
        case .wantToRead:
            return "Add books you want to read next"
        case .completed:
            return "Finish reading a book to see it here"
        case .none:
            return "Add your first book to get started"
        }
    }
}

// MARK: - Currently Reading Card (Hero Section)

struct CurrentlyReadingCard: View {
    let userBook: UserBook
    let onContinue: () -> Void

    private var book: Book? { userBook.book }

    var body: some View {
        Button(action: onContinue) {
            HStack(spacing: 16) {
                // Book cover
                AsyncImage(url: URL(string: book?.coverUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
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
                .frame(width: 60, height: 90)
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Continue Reading")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.quietly.accent)

                    Text(book?.title ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(Color.quietly.textPrimary)
                        .lineLimit(2)

                    if let author = book?.author {
                        Text(author)
                            .font(.subheadline)
                            .foregroundColor(Color.quietly.textSecondary)
                            .lineLimit(1)
                    }

                    ProgressView(value: userBook.progress)
                        .tint(Color.quietly.accent)
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color.quietly.accent)
            }
            .padding()
            .background(Color.quietly.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.quietly.shadowBook, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Book Card

struct AddBookCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Match cover aspect ratio (2:3) with content
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color.quietly.primary)

                    Text("Add Book")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.quietly.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(2/3, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            Color.quietly.primary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6])
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Match info section height
                Spacer()
                    .frame(height: 60)
            }
        }
    }
}

// MARK: - Goal Progress Section

struct GoalProgressSection: View {
    let progressList: [GoalProgress]

    @State private var hasAppeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Goals")
                    .font(.headline)
                    .foregroundColor(Color.quietly.textPrimary)

                Spacer()

                NavigationLink {
                    GoalsView()
                } label: {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(Color.quietly.primary)
                }
            }

            // Show daily/weekly goals prominently
            ForEach(progressList.filter { $0.goal.goalType == .dailyMinutes || $0.goal.goalType == .weeklyMinutes }) { progress in
                MiniGoalCard(progress: progress, hasAppeared: hasAppeared)
            }

            // Show book goals in a compact row
            let bookGoals = progressList.filter { $0.goal.goalType == .booksPerMonth || $0.goal.goalType == .booksPerYear }
            if !bookGoals.isEmpty {
                HStack(spacing: 12) {
                    ForEach(bookGoals) { progress in
                        CompactGoalBadge(progress: progress)
                    }
                }
            }
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                hasAppeared = true
            }
        }
    }
}

// MARK: - Mini Goal Card

struct MiniGoalCard: View {
    let progress: GoalProgress
    let hasAppeared: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: progress.goal.goalType.iconName)
                    .font(.subheadline)
                    .foregroundColor(progress.isComplete ? Color.quietly.success : Color.quietly.accent)
                    .symbolEffect(.bounce, value: progress.isComplete && hasAppeared)

                Text(progress.goal.goalType.displayName)
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textPrimary)

                Spacer()

                Text(progress.progressText)
                    .font(.caption)
                    .foregroundColor(Color.quietly.textSecondary)

                if progress.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(Color.quietly.success)
                        .symbolEffect(.pulse.wholeSymbol, options: .repeating.speed(0.5), value: hasAppeared)
                }
            }

            ProgressView(value: progress.progress)
                .tint(progress.isComplete ? Color.quietly.success : Color.quietly.accent)
        }
    }
}

// MARK: - Compact Goal Badge

struct CompactGoalBadge: View {
    let progress: GoalProgress

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: progress.goal.goalType.iconName)
                .font(.caption)
                .foregroundColor(progress.isComplete ? Color.quietly.success : Color.quietly.textSecondary)

            Text("\(progress.currentValue)/\(progress.targetValue)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(progress.isComplete ? Color.quietly.success : Color.quietly.textPrimary)

            Text(progress.goal.goalType == .booksPerMonth ? "this month" : "this year")
                .font(.caption2)
                .foregroundColor(Color.quietly.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.quietly.secondary)
        .cornerRadius(20)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
