import SwiftUI
import AVFoundation

struct ScanTextSheet: View {
    @StateObject private var viewModel = ScanTextViewModel()
    @Environment(\.dismiss) private var dismiss
    let onSave: (String) async throws -> Void

    var body: some View {
        NavigationStack {
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

                        HStack(spacing: 12) {
                            Button {
                                viewModel.retake()
                            } label: {
                                Label("Retake", systemImage: "arrow.counterclockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)

                            Button {
                                Task {
                                    try? await onSave(viewModel.extractedText)
                                    dismiss()
                                }
                            } label: {
                                Label("Save", systemImage: "checkmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.quietly.primary)
                            .disabled(viewModel.extractedText.trimmed.isEmpty)
                        }
                    }
                } else {
                    // Camera or image picker
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

                Spacer()
            }
            .padding()
            .navigationTitle("Scan Page")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
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
        }
    }
}

// MARK: - Scan Text ViewModel
@MainActor
class ScanTextViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var extractedText = ""
    @Published var isProcessing = false
    @Published var progress: Double = 0
    @Published var error: String?
    @Published var showCamera = false
    @Published var showPhotoPicker = false

    private let ocrService = OCRService()

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
