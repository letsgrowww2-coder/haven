import Foundation
import UIKit
import Combine

@MainActor
class VaultViewModel: ObservableObject {
    @Published var documents: [HavenDocument] = []
    @Published var isLoading = false
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0
    @Published var errorMessage: String?
    @Published var selectedDocument: HavenDocument?
    @Published var aiSummary: String?
    @Published var isGeneratingSummary = false

    private let firebase = FirebaseService.shared
    private let claude = ClaudeService.shared

    func load(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            documents = try await firebase.fetchDocuments(userId: userId)
        } catch {
            errorMessage = "Could not load documents."
        }
    }

    func upload(data: Data, name: String, category: HavenDocument.DocumentCategory, userId: String) async {
        isUploading = true
        uploadProgress = 0
        defer { isUploading = false }
        do {
            let doc = try await firebase.uploadDocument(
                data: data, name: name, category: category, userId: userId
            ) { [weak self] p in self?.uploadProgress = p }
            documents.insert(doc, at: 0)
        } catch {
            errorMessage = "Upload failed. Please try again."
        }
    }

    func delete(_ doc: HavenDocument, userId: String) async {
        do {
            try await firebase.deleteDocument(doc, userId: userId)
            documents.removeAll { $0.id == doc.id }
        } catch {
            errorMessage = "Could not delete document."
        }
    }

    func generateSummary(for doc: HavenDocument, extractedText: String, language: HavenUser.Language) async {
        isGeneratingSummary = true
        defer { isGeneratingSummary = false }
        do {
            aiSummary = try await claude.summarizeDocument(text: extractedText, language: language)
        } catch {
            aiSummary = "Could not generate summary. Please check your connection and try again."
        }
    }
}
