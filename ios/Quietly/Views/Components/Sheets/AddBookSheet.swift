import SwiftUI
import SwiftData

struct AddBookSheet: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AddBookViewModel()
    @Environment(\.dismiss) private var dismiss
    var onBookAdded: (() -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Method picker
                Picker("Method", selection: $viewModel.selectedMethod) {
                    ForEach(AddBookMethod.allCases) { method in
                        Label(method.title, systemImage: method.icon)
                            .tag(method)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Divider()

                // Content based on selected method
                ScrollView {
                    switch viewModel.selectedMethod {
                    case .search:
                        searchView
                    case .isbn:
                        isbnView
                    case .manual:
                        manualView
                    }
                }
            }
            .background(Color.quietly.background)
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .loadingOverlay(viewModel.isLoading)
        }
    }

    // MARK: - Search View
    private var searchView: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Search by title or author", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await viewModel.searchBooks() }
                    }

                Button {
                    Task { await viewModel.searchBooks() }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .padding(10)
                        .background(Color.quietly.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(!viewModel.canSearch)
            }
            .padding(.horizontal)

            if viewModel.hasSearched && viewModel.searchResults.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No results",
                    message: "Try a different search term"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.searchResults) { result in
                        SearchResultCard(book: result) {
                            let _ = viewModel.selectSearchResult(result, context: modelContext)
                            onBookAdded?()
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }

    // MARK: - ISBN View
    private var isbnView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter ISBN")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)

                HStack {
                    TextField("ISBN-10 or ISBN-13", text: $viewModel.isbnInput)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)

                    Button {
                        Task { await viewModel.lookupISBN() }
                    } label: {
                        Text("Lookup")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.quietly.primary)
                    .disabled(viewModel.isbnInput.cleanedISBN.isEmpty)
                }

                if let error = viewModel.isbnError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color.quietly.destructive)
                }
            }
            .padding(.horizontal)

            if let book = viewModel.isbnBook {
                VStack(spacing: 16) {
                    BookPreviewCard(book: book)

                    Button {
                        if let _ = viewModel.addISBNBook(context: modelContext) {
                            onBookAdded?()
                            dismiss()
                        }
                    } label: {
                        Text("Add to Library")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.quietly.accent)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
    }

    // MARK: - Manual View
    private var manualView: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Title *")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)

                TextField("Book title", text: $viewModel.manualTitle)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Author")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)

                TextField("Author name", text: $viewModel.manualAuthor)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Page Count")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)

                TextField("Number of pages", text: $viewModel.manualPageCount)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Cover URL (optional)")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)

                TextField("https://...", text: $viewModel.manualCoverUrl)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            Button {
                if let _ = viewModel.addManualBook(context: modelContext) {
                    onBookAdded?()
                    dismiss()
                }
            } label: {
                Text("Add to Library")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.quietly.primary)
            .disabled(!viewModel.canAddManual)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
    let book: OpenLibraryBook
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: book.coverUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(Color.quietly.secondary)
                            .overlay(
                                Image(systemName: "book.closed")
                                    .foregroundColor(Color.quietly.mutedForeground)
                            )
                    }
                }
                .frame(width: 50, height: 75)
                .cornerRadius(4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.quietly.textPrimary)
                        .lineLimit(2)

                    if let author = book.author {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(Color.quietly.textSecondary)
                            .lineLimit(1)
                    }

                    if let year = book.firstPublishYear {
                        Text(String(year))
                            .font(.caption2)
                            .foregroundColor(Color.quietly.textMuted)
                    }
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color.quietly.primary)
            }
            .padding()
            .background(Color.quietly.card)
            .cornerRadius(12)
        }
    }
}

// MARK: - Book Preview Card
struct BookPreviewCard: View {
    let book: Book

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: book.coverUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Color.quietly.secondary)
                        .overlay(
                            Image(systemName: "book.closed")
                                .font(.title2)
                                .foregroundColor(Color.quietly.mutedForeground)
                        )
                }
            }
            .frame(width: 80, height: 120)
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(Color.quietly.textPrimary)

                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                }

                if let pages = book.pageCount {
                    Text("\(pages) pages")
                        .font(.caption)
                        .foregroundColor(Color.quietly.textMuted)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.quietly.card)
        .cornerRadius(12)
    }
}

#Preview {
    AddBookSheet()
        .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
