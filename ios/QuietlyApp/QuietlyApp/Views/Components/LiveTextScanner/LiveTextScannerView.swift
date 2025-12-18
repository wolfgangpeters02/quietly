import SwiftUI
import VisionKit

/// A SwiftUI view that provides live text scanning using the camera
/// Users can tap on recognized text to select it
@MainActor
struct LiveTextScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var isPresented: Bool
    var onTextSelected: ((String) -> Void)?

    static var isSupported: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator

        // Start scanning immediately
        try? scanner.startScanning()

        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Ensure scanning is active
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: LiveTextScannerView

        init(_ parent: LiveTextScannerView) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.scannedText = text.transcript
                parent.onTextSelected?(text.transcript)
            default:
                break
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Items are highlighted automatically
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Handle removed items if needed
        }

        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            parent.isPresented = false
        }
    }
}

// MARK: - Live Text Scanner Sheet
struct LiveTextScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scannedText = ""
    @State private var selectedTexts: [String] = []
    @State private var isScanning = true
    @State private var showUnsupportedAlert = false

    let onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                if LiveTextScannerView.isSupported {
                    scannerView
                } else {
                    unsupportedView
                }
            }
            .navigationTitle("Scan Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if !selectedTexts.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            let combinedText = selectedTexts.joined(separator: "\n")
                            onSave(combinedText)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var scannerView: some View {
        VStack(spacing: 0) {
            // Scanner
            LiveTextScannerView(
                scannedText: $scannedText,
                isPresented: $isScanning
            ) { text in
                // Add to selected texts
                if !selectedTexts.contains(text) {
                    selectedTexts.append(text)
                }
            }
            .ignoresSafeArea(edges: .horizontal)

            // Selected text preview
            VStack(spacing: 12) {
                if selectedTexts.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .foregroundColor(Color.quietly.primary)
                        Text("Tap on text to select it")
                            .font(.subheadline)
                            .foregroundColor(Color.quietly.textSecondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Selected Text")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.quietly.textSecondary)

                                Spacer()

                                Button {
                                    selectedTexts.removeAll()
                                } label: {
                                    Text("Clear")
                                        .font(.caption)
                                        .foregroundColor(Color.quietly.destructive)
                                }
                            }

                            ForEach(Array(selectedTexts.enumerated()), id: \.offset) { index, text in
                                HStack(alignment: .top) {
                                    Text(text)
                                        .font(.subheadline)
                                        .foregroundColor(Color.quietly.textPrimary)

                                    Spacer()

                                    Button {
                                        selectedTexts.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color.quietly.textMuted)
                                    }
                                }
                                .padding(12)
                                .background(Color.quietly.card)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                    .padding()
                }
            }
            .background(Color.quietly.background)
        }
    }

    private var unsupportedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 60))
                .foregroundColor(Color.quietly.textMuted)

            Text("Live Text Not Available")
                .font(.headline)
                .foregroundColor(Color.quietly.textPrimary)

            Text("Your device doesn't support live text scanning. Please use the photo option instead.")
                .font(.subheadline)
                .foregroundColor(Color.quietly.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    LiveTextScannerSheet { text in
        print("Saved: \(text)")
    }
}
