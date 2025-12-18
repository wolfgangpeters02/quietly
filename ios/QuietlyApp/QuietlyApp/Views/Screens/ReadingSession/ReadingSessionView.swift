import SwiftUI
import SwiftData
import TipKit

struct ReadingSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ReadingSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showScanText = false

    // Tips
    private let scanTextTip = ScanTextTip()

    init(userBook: UserBook) {
        guard let book = userBook.book else {
            fatalError("UserBook must have an associated Book")
        }
        _viewModel = StateObject(wrappedValue: ReadingSessionViewModel(book: book, userBook: userBook))
    }

    var body: some View {
        VStack(spacing: 24) {
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
            VStack(spacing: 8) {
                Text(viewModel.formattedTime)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.quietly.textPrimary)
                    .contentTransition(.numericText())

                if viewModel.isReading {
                    Text("Reading")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.quietly.accent)
                } else if viewModel.isPaused {
                    Text("Paused")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.quietly.textMuted)
                }
            }
            .padding(.vertical, 16)

            // Starting page input (before session starts)
            if viewModel.canStart {
                VStack(spacing: 8) {
                    Text("Starting Page")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)

                    TextField("0", value: $viewModel.startPage, format: .number)
                        .textFieldStyle(.quietly(width: 100))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                }
            }

            // Control buttons
            controlButtons

            // Session notes (during active session)
            if viewModel.session != nil {
                TipView(scanTextTip)
                    .padding(.horizontal)
                sessionNotesSection
            }

            Spacer()
        }
        .padding()
        .background(Color.quietly.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Reading Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .sheet(isPresented: $viewModel.showEndDialog) {
            endSessionSheet
        }
        .sheet(isPresented: $showScanText) {
            ScanTextSheet { scannedText in
                viewModel.addScannedNote(scannedText, context: modelContext)
            }
        }
        .onAppear {
            viewModel.checkForActiveSession(context: modelContext)
        }
        .onDisappear {
            viewModel.cleanup()
        }
        .onChange(of: viewModel.isReading) { _, isReading in
            if isReading {
                ScanTextTip.hasStartedSession = true
            }
        }
    }

    // MARK: - Control Buttons
    @State private var playButtonTrigger = false
    @State private var pauseButtonTrigger = false
    @State private var stopButtonTrigger = false

    private var controlButtons: some View {
        HStack(spacing: 16) {
            if viewModel.canStart {
                Button {
                    playButtonTrigger.toggle()
                    viewModel.startSession(context: modelContext)
                } label: {
                    Label("Start Reading", systemImage: "play.fill")
                        .symbolEffect(.bounce, value: playButtonTrigger)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.accent)
            } else {
                if viewModel.isReading {
                    Button {
                        pauseButtonTrigger.toggle()
                        viewModel.pauseSession(context: modelContext)
                    } label: {
                        Label("Pause", systemImage: "pause.fill")
                            .symbolEffect(.bounce, value: pauseButtonTrigger)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.quietly.primary)
                } else if viewModel.isPaused {
                    Button {
                        playButtonTrigger.toggle()
                        viewModel.resumeSession(context: modelContext)
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .symbolEffect(.bounce, value: playButtonTrigger)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.quietly.accent)
                }

                Button {
                    stopButtonTrigger.toggle()
                    viewModel.showEndDialog = true
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .symbolEffect(.bounce, value: stopButtonTrigger)
                        .font(.headline)
                        .frame(minWidth: 100, minHeight: 50)
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
            HStack {
                Text("Notes")
                    .font(.headline)
                    .foregroundColor(Color.quietly.textPrimary)

                Spacer()

                // Scan quote button
                Button {
                    showScanText = true
                } label: {
                    Label("Scan", systemImage: "viewfinder")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.primary)
                }
            }

            // Quick note input with optional page
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    TextField("Add a note...", text: $viewModel.noteContent)
                        .textFieldStyle(.quietly)

                    // Optional page number input
                    HStack(spacing: 4) {
                        Text("p.")
                            .font(.caption)
                            .foregroundColor(Color.quietly.textMuted)
                        TextField("", value: $viewModel.notePageNumber, format: .number)
                            .textFieldStyle(.quietly(width: 50))
                            .keyboardType(.numberPad)
                    }

                    Button {
                        viewModel.addSessionNote(context: modelContext)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.quietly.primary)
                    }
                    .disabled(viewModel.noteContent.trimmed.isEmpty)
                }
            }

            // Notes list
            if !viewModel.sessionNotes.isEmpty {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.sessionNotes) { note in
                            SessionNoteCard(note: note) {
                                viewModel.deleteNote(note, context: modelContext)
                            }
                        }
                    }
                }
                .frame(maxHeight: 180)
            } else {
                Text("Add notes or scan text from your book")
                    .font(.caption)
                    .foregroundColor(Color.quietly.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - End Session Sheet
    private var endSessionSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with icon
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color.quietly.success)

                        Text("End Reading Session")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.quietly.textPrimary)

                        Text("You read for \(viewModel.formattedTime)")
                            .font(.subheadline)
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                    .padding(.top, 8)

                    // Page input
                    VStack(spacing: 8) {
                        Text("Ending Page")
                            .font(.subheadline)
                            .foregroundColor(Color.quietly.textSecondary)

                        TextField("Page", value: $viewModel.endPage, format: .number)
                            .textFieldStyle(.quietly(width: 120))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)

                        if viewModel.pagesRead > 0 {
                            Text("You read \(viewModel.pagesRead) pages")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color.quietly.accent)
                        }
                    }

                    // Session summary
                    if !viewModel.sessionNotes.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "note.text")
                            Text("Notes captured: \(viewModel.sessionNotes.count)")
                        }
                        .font(.caption)
                        .foregroundColor(Color.quietly.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.quietly.secondary)
                        .clipShape(Capsule())
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button {
                    if viewModel.endSession(context: modelContext) {
                        dismiss()
                    }
                } label: {
                    Text("Save Session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.primary)
                .padding()
                .background(.ultraThinMaterial)
            }
            .background(Color.quietly.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showEndDialog = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Session Note Card
struct SessionNoteCard: View {
    let note: Note
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Note icon
            Image(systemName: "note.text")
                .font(.caption)
                .foregroundColor(Color.quietly.primary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(Color.quietly.textPrimary)
                    .lineLimit(3)

                if let pageLabel = note.pageLabel {
                    Text(pageLabel)
                        .font(.caption2)
                        .foregroundColor(Color.quietly.textMuted)
                }
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.quietly.textMuted)
            }
        }
        .padding(12)
        .background(Color.quietly.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ReadingSessionView(
            userBook: UserBook(
                book: Book(
                    title: "The Great Gatsby",
                    author: "F. Scott Fitzgerald",
                    pageCount: 180
                ),
                status: .reading,
                currentPage: 45,
                startedAt: Date()
            )
        )
    }
    .modelContainer(for: [Book.self, UserBook.self, Note.self, ReadingSession.self, ReadingGoal.self], inMemory: true)
}
