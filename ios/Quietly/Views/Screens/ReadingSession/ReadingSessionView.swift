import SwiftUI
import SwiftData
import TipKit

struct ReadingSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ReadingSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showScanText = false
    @State private var isAnimatingTimer = false

    // Tips
    private let captureQuoteTip = CaptureQuoteTip()

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
            HStack(spacing: 12) {
                if viewModel.isReading {
                    Image(systemName: "waveform")
                        .font(.title2)
                        .foregroundColor(Color.quietly.accent)
                        .symbolEffect(.variableColor.iterative.reversing, options: .repeating, value: isAnimatingTimer)
                }

                Text(viewModel.formattedTime)
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.quietly.textPrimary)
                    .contentTransition(.numericText())

                if viewModel.isReading {
                    Image(systemName: "waveform")
                        .font(.title2)
                        .foregroundColor(Color.quietly.accent)
                        .symbolEffect(.variableColor.iterative.reversing, options: .repeating, value: isAnimatingTimer)
                }
            }
            .padding(.vertical, 16)
            .onChange(of: viewModel.isReading) { _, isReading in
                isAnimatingTimer = isReading
            }

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
                TipView(captureQuoteTip)
                    .padding(.horizontal)
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
        .sheet(isPresented: $showScanText) {
            ScanTextSheet { scannedText in
                viewModel.addScannedQuote(scannedText, context: modelContext)
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
                CaptureQuoteTip.hasStartedSession = true
            }
        }
    }

    // MARK: - Control Buttons
    @State private var playButtonTrigger = false
    @State private var pauseButtonTrigger = false
    @State private var stopButtonTrigger = false

    private var controlButtons: some View {
        HStack(spacing: 20) {
            if viewModel.canStart {
                Button {
                    playButtonTrigger.toggle()
                    viewModel.startSession(context: modelContext)
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                            .symbolEffect(.bounce, value: playButtonTrigger)
                        Text("Start Reading")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.quietly.accent)
            } else {
                if viewModel.isReading {
                    Button {
                        pauseButtonTrigger.toggle()
                        viewModel.pauseSession(context: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "pause.fill")
                                .symbolEffect(.bounce, value: pauseButtonTrigger)
                            Text("Pause")
                        }
                        .font(.headline)
                        .padding()
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.quietly.primary)
                } else if viewModel.isPaused {
                    Button {
                        playButtonTrigger.toggle()
                        viewModel.resumeSession(context: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .symbolEffect(.bounce, value: playButtonTrigger)
                            Text("Resume")
                        }
                        .font(.headline)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.quietly.accent)
                }

                Button {
                    stopButtonTrigger.toggle()
                    viewModel.showEndDialog = true
                } label: {
                    HStack {
                        Image(systemName: "stop.fill")
                            .symbolEffect(.bounce, value: stopButtonTrigger)
                        Text("Stop")
                    }
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
            HStack {
                Text("Notes & Quotes")
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

            // Quick note input
            HStack(spacing: 12) {
                TextField("Add a note...", text: $viewModel.noteContent)
                    .textFieldStyle(.roundedBorder)

                Button {
                    viewModel.addSessionNote(context: modelContext)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.quietly.primary)
                }
                .disabled(viewModel.noteContent.trimmed.isEmpty)
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
                Text("Tap text in your book to capture quotes")
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

                // Session summary
                if !viewModel.sessionNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes captured: \(viewModel.sessionNotes.count)")
                            .font(.caption)
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                }

                Spacer()

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

// MARK: - Session Note Card
struct SessionNoteCard: View {
    let note: Note
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Type indicator
            Image(systemName: note.noteType == .quote ? "quote.opening" : "note.text")
                .font(.caption)
                .foregroundColor(note.noteType == .quote ? Color.quietly.accent : Color.quietly.primary)
                .frame(width: 20)

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(Color.quietly.textPrimary)
                .lineLimit(3)

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
        .cornerRadius(8)
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
