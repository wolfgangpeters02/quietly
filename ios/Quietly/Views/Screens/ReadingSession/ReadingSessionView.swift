import SwiftUI

struct ReadingSessionView: View {
    @StateObject private var viewModel: ReadingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    init(userBook: UserBook) {
        guard let book = userBook.book else {
            fatalError("UserBook must have an associated Book")
        }
        _viewModel = StateObject(wrappedValue: ReadingSessionViewModel(book: book, userBook: userBook))
    }

    var body: some View {
        VStack(spacing: 32) {
            // Book info
            VStack(spacing: 8) {
                Text(viewModel.book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.quietly.textPrimary)

                if let author = viewModel.book.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                }
            }
            .padding(.top)

            // Timer display
            Text(viewModel.formattedTime)
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .foregroundColor(Color.quietly.textPrimary)
                .padding(.vertical, 24)

            // Starting page input (before session starts)
            if viewModel.canStart {
                VStack(spacing: 8) {
                    Text("Starting Page")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    TextField("0", value: $viewModel.startPage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                }
            }

            // Control buttons
            controlButtons

            // Session notes (during active session)
            if viewModel.session != nil {
                sessionNotesSection
            }

            Spacer()
        }
        .padding()
        .background(Color.quietly.background)
        .navigationTitle("Reading Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $viewModel.showEndDialog) {
            endSessionSheet
        }
        .task {
            await viewModel.checkForActiveSession()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 20) {
            if viewModel.canStart {
                Button {
                    Task { await viewModel.startSession() }
                } label: {
                    Label("Start Reading", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.accent)
            } else {
                if viewModel.isReading {
                    Button {
                        Task { await viewModel.pauseSession() }
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                            .font(.headline)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.quietly.primary)
                } else if viewModel.isPaused {
                    Button {
                        Task { await viewModel.resumeSession() }
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .font(.headline)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.quietly.accent)
                }

                Button {
                    viewModel.showEndDialog = true
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(.bordered)
                .tint(Color.quietly.destructive)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Session Notes Section
    private var sessionNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Notes")
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)

            HStack(spacing: 12) {
                TextField("Add a note...", text: $viewModel.noteContent)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await viewModel.addSessionNote() }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.quietly.primary)
                }
                .disabled(viewModel.noteContent.trimmed.isEmpty)
            }

            if !viewModel.sessionNotes.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.sessionNotes) { note in
                            HStack {
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(Color.quietly.textPrimary)

                                Spacer()

                                Button {
                                    Task { await viewModel.deleteNote(note) }
                                } label: {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(Color.quietly.destructive)
                                }
                            }
                            .padding()
                            .background(Color.quietly.card)
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - End Session Sheet
    private var endSessionSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("End Reading Session")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.quietly.textPrimary)

                Text("You read for \(viewModel.formattedTime)")
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textSecondary)

                VStack(spacing: 8) {
                    Text("Ending Page")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    TextField("Page", value: $viewModel.endPage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 120)

                    if viewModel.pagesRead > 0 {
                        Text("You read \(viewModel.pagesRead) pages")
                            .font(.caption)
                            .foregroundColor(Color.quietly.accent)
                    }
                }

                Spacer()

                Button {
                    Task {
                        if await viewModel.endSession() {
                            dismiss()
                        }
                    }
                } label: {
                    Text("Save Session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.primary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showEndDialog = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        ReadingSessionView(
            userBook: UserBook(
                id: UUID(),
                userId: UUID(),
                bookId: UUID(),
                status: .reading,
                currentPage: 45,
                rating: nil,
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
