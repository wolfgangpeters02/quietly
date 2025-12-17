import SwiftUI
import AVFoundation
import VisionKit

enum ScanMode: String, CaseIterable, Identifiable {
    case live
    case photo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .live: return "Live"
        case .photo: return "Photo"
        }
    }

    var icon: String {
        switch self {
        case .live: return "viewfinder"
        case .photo: return "photo"
        }
    }
}

struct ScanTextSheet: View {
    @StateObject private var viewModel = ScanTextViewModel()
    @Environment(\.dismiss) private var dismiss
    let onSave: (String) -> Void

    // Check if live scanning is available
    private var isLiveScanSupported: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode picker (only show if live is supported)
                if isLiveScanSupported {
                    Picker("Scan Mode", selection: $viewModel.scanMode) {
                        ForEach(ScanMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }

                Divider()

                // Content based on mode
                switch viewModel.scanMode {
                case .live:
                    if isLiveScanSupported {
                        liveScanView
                    } else {
                        photoScanView
                    }
                case .photo:
                    photoScanView
                }
            }
            .background(Color.quietly.background)
            .navigationTitle("Scan Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if viewModel.canSave {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onSave(viewModel.finalText)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCamera) {
                ImagePicker(image: $viewModel.capturedImage, sourceType: .camera)
            }
            .sheet(isPresented: $viewModel.showPhotoPicker) {
                ImagePicker(image: $viewModel.capturedImage, sourceType: .photoLibrary)
            }
            .onChange(of: viewModel.capturedImage) { _, newImage in
                if newImage != nil {
                    Task { await viewModel.processImage() }
                }
            }
            .onAppear {
                // Default to live mode if supported
                if !isLiveScanSupported {
                    viewModel.scanMode = .photo
                }
            }
        }
    }

    // MARK: - Live Scan View
    @ViewBuilder
    private var liveScanView: some View {
        VStack(spacing: 0) {
            // Scanner
            LiveTextScannerView(
                scannedText: $viewModel.lastScannedText,
                isPresented: .constant(true)
            ) { text in
                viewModel.addSelectedText(text)
            }
            .ignoresSafeArea(edges: .horizontal)

            // Selected text panel
            selectedTextPanel
        }
    }

    // MARK: - Photo Scan View
    private var photoScanView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let image = viewModel.capturedImage {
                    // Image preview
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)

                    if viewModel.isProcessing {
                        VStack(spacing: 12) {
                            ProgressView(value: viewModel.progress)
                                .tint(Color.quietly.accent)

                            Text("Recognizing text... \(Int(viewModel.progress * 100))%")
                                .font(.caption)
                                .foregroundColor(Color.quietly.textSecondary)
                        }
                        .padding()
                    } else {
                        // Editable text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Extracted Text")
                                .font(.subheadline)
                                .foregroundColor(Color.quietly.textSecondary)

                            TextEditor(text: $viewModel.extractedText)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color.quietly.secondary.opacity(0.3))
                                .cornerRadius(8)
                        }

                        Button {
                            viewModel.retake()
                        } label: {
                            Label("Retake Photo", systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    // Camera/photo picker options
                    VStack(spacing: 24) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(Color.quietly.primary)

                        Text("Scan text from a page")
                            .font(.headline)
                            .foregroundColor(Color.quietly.textPrimary)

                        Text("Take a photo of a book page to extract text")
                            .font(.subheadline)
                            .foregroundColor(Color.quietly.textSecondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 16) {
                            Button {
                                viewModel.showCamera = true
                            } label: {
                                Label("Camera", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.quietly.primary)

                            Button {
                                viewModel.showPhotoPicker = true
                            } label: {
                                Label("Photos", systemImage: "photo")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                }

                if let error = viewModel.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color.quietly.destructive)
                        .padding()
                }
            }
            .padding()
        }
    }

    // MARK: - Selected Text Panel
    private var selectedTextPanel: some View {
        VStack(spacing: 12) {
            if viewModel.selectedTexts.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap")
                        .foregroundColor(Color.quietly.primary)
                    Text("Tap on highlighted text to select")
                        .font(.subheadline)
                        .foregroundColor(Color.quietly.textSecondary)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Selected (\(viewModel.selectedTexts.count))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color.quietly.textSecondary)

                            Spacer()

                            Button {
                                viewModel.clearSelectedTexts()
                            } label: {
                                Text("Clear All")
                                    .font(.caption)
                                    .foregroundColor(Color.quietly.destructive)
                            }
                        }

                        ForEach(Array(viewModel.selectedTexts.enumerated()), id: \.offset) { index, text in
                            HStack(alignment: .top, spacing: 8) {
                                Text(text)
                                    .font(.subheadline)
                                    .foregroundColor(Color.quietly.textPrimary)
                                    .lineLimit(3)

                                Spacer()

                                Button {
                                    viewModel.removeSelectedText(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.quietly.textMuted)
                                        .font(.caption)
                                }
                            }
                            .padding(10)
                            .background(Color.quietly.card)
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(maxHeight: 140)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .background(Color.quietly.background)
    }
}

// MARK: - Scan Text ViewModel
@MainActor
class ScanTextViewModel: ObservableObject {
    @Published var scanMode: ScanMode = .live
    @Published var capturedImage: UIImage?
    @Published var extractedText = ""
    @Published var isProcessing = false
    @Published var progress: Double = 0
    @Published var error: String?
    @Published var showCamera = false
    @Published var showPhotoPicker = false

    // Live scanning
    @Published var lastScannedText = ""
    @Published var selectedTexts: [String] = []

    private let ocrService = OCRService()

    var canSave: Bool {
        switch scanMode {
        case .live:
            return !selectedTexts.isEmpty
        case .photo:
            return !extractedText.trimmed.isEmpty
        }
    }

    var finalText: String {
        switch scanMode {
        case .live:
            return selectedTexts.joined(separator: "\n")
        case .photo:
            return extractedText.trimmed
        }
    }

    func addSelectedText(_ text: String) {
        let trimmed = text.trimmed
        guard !trimmed.isEmpty, !selectedTexts.contains(trimmed) else { return }
        selectedTexts.append(trimmed)
        HapticService.shared.textScanned()
    }

    func removeSelectedText(at index: Int) {
        guard index < selectedTexts.count else { return }
        selectedTexts.remove(at: index)
    }

    func clearSelectedTexts() {
        selectedTexts.removeAll()
    }

    func processImage() async {
        guard let image = capturedImage else { return }

        isProcessing = true
        progress = 0
        error = nil

        do {
            extractedText = try await ocrService.recognizeText(from: image) { [weak self] progress in
                Task { @MainActor in
                    self?.progress = progress
                }
            }
        } catch {
            self.error = error.localizedDescription
            extractedText = ""
        }

        isProcessing = false
    }

    func retake() {
        capturedImage = nil
        extractedText = ""
        error = nil
        progress = 0
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ScanTextSheet { text in
        print("Saved: \(text)")
    }
}
