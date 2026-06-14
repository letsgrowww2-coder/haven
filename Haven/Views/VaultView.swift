import SwiftUI
import PhotosUI

struct VaultView: View {
    @StateObject private var viewModel = VaultViewModel()
    @EnvironmentObject var appState: AppState
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pendingImageData: Data?
    @State private var showUploadSheet = false
    @State private var selectedCategory: HavenDocument.DocumentCategory = .other

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading documents…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.documents.isEmpty {
                    emptyState
                } else {
                    documentGrid
                }
            }
            .navigationTitle(L10n.t(.navMyDocuments))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .any(of: [.images, .screenshots])
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .havenSOS()
            // Load saved documents every time this tab becomes visible
            .task {
                await viewModel.load(userId: appState.userId)
            }
            .onChange(of: selectedPhoto) { _, item in
                guard let item else { return }
                Task {
                    do {
                        // loadTransferable returns the raw bytes; works for JPEG, PNG, HEIC
                        if let data = try await item.loadTransferable(type: Data.self), !data.isEmpty {
                            // Convert HEIC/HEIF to JPEG so UIImage can always display it
                            let imageData: Data
                            if let uiImage = UIImage(data: data),
                               let jpeg = uiImage.jpegData(compressionQuality: 0.85) {
                                imageData = jpeg
                            } else {
                                imageData = data
                            }
                            await MainActor.run {
                                pendingImageData = imageData
                                showUploadSheet = true
                            }
                        } else {
                            await MainActor.run {
                                viewModel.errorMessage = "Could not load the selected photo. Please try another."
                            }
                        }
                    } catch {
                        await MainActor.run {
                            viewModel.errorMessage = "Photo load failed: \(error.localizedDescription)"
                        }
                    }
                    // Always reset so the same photo can be picked again next time
                    await MainActor.run { selectedPhoto = nil }
                }
            }
            // Reset selection state when sheet closes (dismissed without saving)
            .sheet(isPresented: $showUploadSheet, onDismiss: {
                selectedPhoto = nil
                pendingImageData = nil
            }) {
                UploadDocumentSheet(imageData: pendingImageData, viewModel: viewModel)
            }
            .sheet(item: $viewModel.selectedDocument) { doc in
                DocumentViewer(document: doc, viewModel: viewModel)
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var documentGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.documents) { doc in
                    DocumentCard(document: doc)
                        .onTapGesture { viewModel.selectedDocument = doc }
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    let uid = appState.userId
                                    await viewModel.delete(doc, userId: uid)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.6))

            Text("Your Secure Vault")
                .font(.title2.bold())

            Text("Store important documents here — ID, housing paperwork, medical records. Everything is saved privately on your device.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            PhotosPicker(
                selection: $selectedPhoto,
                matching: .any(of: [.images, .screenshots]),
                photoLibrary: .shared()
            ) {
                Label("Add Your First Document", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Document Card

struct DocumentCard: View {
    let document: HavenDocument

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: document.category.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(document.name)
                .font(.subheadline.bold())
                .lineLimit(2)
                .foregroundColor(.primary)

            Text(document.category.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(document.uploadedAt.timeAgoDisplay())
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .havenCard()
    }
}

// MARK: - Upload Sheet

struct UploadDocumentSheet: View {
    let imageData: Data?
    @ObservedObject var viewModel: VaultViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: HavenDocument.DocumentCategory = .id

    var body: some View {
        NavigationStack {
            Form {
                if let data = imageData, let img = UIImage(data: data) {
                    Section {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                Section("Document Details") {
                    TextField("Document name (e.g. State ID)", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(HavenDocument.DocumentCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }

                Section {
                    Label("Encrypted with AES-256. Only you can access this.", systemImage: "lock.shield.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard let data = imageData, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        Task {
                            let uid = appState.userId
                            await viewModel.upload(
                                data: data,
                                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                category: category,
                                userId: uid
                            )
                            // Only dismiss if upload succeeded (no error set)
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || imageData == nil || viewModel.isUploading)
                }
            }
            .overlay {
                if viewModel.isUploading {
                    ZStack {
                        Color.black.opacity(0.3)
                        VStack(spacing: 12) {
                            ProgressView(value: viewModel.uploadProgress)
                                .tint(.white)
                                .frame(width: 200)
                            Text("Encrypting & uploading…")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .ignoresSafeArea()
                }
            }
        }
    }
}

// MARK: - Document Viewer

struct DocumentViewer: View {
    let document: HavenDocument
    @ObservedObject var viewModel: VaultViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 14) {
                        Image(systemName: document.category.icon)
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(document.name).font(.headline)
                            Text(document.category.rawValue).font(.caption).foregroundColor(.secondary)
                            Text("Added \(document.uploadedAt.timeAgoDisplay())").font(.caption2).foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .havenCard()

                    if let summary = document.aiSummary ?? viewModel.aiSummary {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("AI Summary", systemImage: "sparkles")
                                .font(.headline)
                            Text(summary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .havenCard()
                    } else if viewModel.isGeneratingSummary {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Generating summary…")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .havenCard()
                    }

                    Button {
                        Task {
                            await viewModel.generateSummary(
                                for: document,
                                extractedText: "Document: \(document.name), Category: \(document.category.rawValue)",
                                language: appState.preferredLanguage
                            )
                        }
                    } label: {
                        Label("Summarize with AI", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isGeneratingSummary)

                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share Securely", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                SharingView(document: document)
            }
        }
    }
}
