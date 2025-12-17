import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedBook: UserBook?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats row
                    HStack(spacing: 12) {
                        StatsCard(
                            title: "Streak",
                            value: "\(viewModel.stats.readingStreak)",
                            subtitle: viewModel.stats.streakLabel,
                            icon: "flame.fill"
                        )

                        StatsCard(
                            title: "Library",
                            value: "\(viewModel.stats.totalBooks)",
                            subtitle: "books",
                            icon: "books.vertical.fill"
                        )

                        StatsCard(
                            title: "Completed",
                            value: "\(viewModel.stats.booksCompleted)",
                            subtitle: "books",
                            icon: "checkmark.circle.fill"
                        )
                    }
                    .padding(.horizontal)

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
                                    BookCard(userBook: userBook) {
                                        selectedBook = userBook
                                    }
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
            .background(Color.quietly.background)
            .navigationTitle(AppConstants.App.name)
            .navigationDestination(for: UserBook.self) { userBook in
                BookDetailView(userBook: userBook)
            }
            .sheet(isPresented: $viewModel.showAddBook) {
                AddBookSheet {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .sheet(item: $selectedBook) { userBook in
                NavigationStack {
                    ReadingSessionView(userBook: userBook)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
            }
            .overlay {
                if viewModel.isLoading && viewModel.userBooks.isEmpty {
                    LoadingView(message: "Loading your library...")
                }
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

struct AddBookCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color.quietly.primary)

                Text("Add Book")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.quietly.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                    .strokeBorder(
                        Color.quietly.primary.opacity(0.3),
                        style: StrokeStyle(lineWidth: 2, dash: [8])
                    )
            )
        }
    }
}

#Preview {
    HomeView()
}
