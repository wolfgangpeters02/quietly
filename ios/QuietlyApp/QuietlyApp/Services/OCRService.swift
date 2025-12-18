import Foundation
import Vision
import UIKit

enum OCRError: LocalizedError {
    case invalidImage
    case recognitionFailed
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the image"
        case .recognitionFailed:
            return "Text recognition failed"
        case .noTextFound:
            return "No text was found in the image"
        }
    }
}

final class OCRService {
    // MARK: - Recognize Text from UIImage
    func recognizeText(from image: UIImage, progressHandler: ((Double) -> Void)? = nil) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.recognitionFailed)
                    return
                }

                if observations.isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }

                // Extract text from observations
                let recognizedStrings = observations.compactMap { observation -> String? in
                    observation.topCandidates(1).first?.string
                }

                let text = recognizedStrings.joined(separator: "\n")

                if text.isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    continuation.resume(returning: text)
                }
            }

            // Configure the request for better accuracy
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true

            // Progress reporting (simulated since Vision doesn't provide real progress)
            progressHandler?(0.1)

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                progressHandler?(0.3)
                try handler.perform([request])
                progressHandler?(1.0)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Recognize Text from Data
    func recognizeText(from imageData: Data, progressHandler: ((Double) -> Void)? = nil) async throws -> String {
        guard let image = UIImage(data: imageData) else {
            throw OCRError.invalidImage
        }

        return try await recognizeText(from: image, progressHandler: progressHandler)
    }

    // MARK: - Recognize Text with Bounding Boxes
    func recognizeTextWithPositions(from image: UIImage) async throws -> [(text: String, boundingBox: CGRect)] {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.recognitionFailed)
                    return
                }

                let results = observations.compactMap { observation -> (String, CGRect)? in
                    guard let text = observation.topCandidates(1).first?.string else {
                        return nil
                    }
                    return (text, observation.boundingBox)
                }

                continuation.resume(returning: results)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
