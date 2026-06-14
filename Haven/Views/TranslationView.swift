import SwiftUI

struct TranslationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""
    @State private var selectedLanguage: HavenUser.Language = .spanish
    @State private var result: String?
    @State private var isTranslating = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Info card
                    Label("Paste any document, notice, or text below. Haven will translate it and explain what it means in plain language.", systemImage: "globe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .havenCard()

                    // Language selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Translate into").font(.subheadline.bold())
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(HavenUser.Language.allCases.filter { $0 != .english }) { lang in
                                    Button(lang.displayName) {
                                        selectedLanguage = lang
                                    }
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedLanguage == lang ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedLanguage == lang ? .white : .primary)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                    .havenCard()

                    // Text input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Text to translate").font(.subheadline.bold())
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $inputText)
                                .font(.subheadline)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            if inputText.isEmpty {
                                Text("Paste or type text here…")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(14)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .padding()
                    .havenCard()

                    // Result
                    if let result {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Translation & Explanation", systemImage: "text.bubble.fill")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                            Text(result)
                                .font(.subheadline)

                            ShareLink(item: result, subject: Text("Translation — Haven")) {
                                Label("Share Translation", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .havenCard()
                    }

                    if let error = errorMessage {
                        Text(error).font(.caption).foregroundColor(.red)
                    }

                    Button {
                        Task { await translate() }
                    } label: {
                        if isTranslating {
                            HStack(spacing: 8) { ProgressView(); Text("Translating…") }
                                .frame(maxWidth: .infinity)
                        } else {
                            Label(result == nil ? "Translate" : "Retranslate", systemImage: "globe")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isTranslating || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Translate & Explain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func translate() async {
        isTranslating = true
        errorMessage = nil
        do {
            result = try await ClaudeService.shared.translate(
                text: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
                into: selectedLanguage
            )
        } catch {
            errorMessage = "Translation failed. Please check your connection and try again."
        }
        isTranslating = false
    }
}
