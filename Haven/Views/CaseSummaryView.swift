import SwiftUI

struct CaseSummaryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // Inputs
    @State private var situation = ""
    @State private var housingNeed = ""
    @State private var background = ""
    @State private var assistanceNeeded = ""

    // Output
    @State private var generatedSummary: String?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showReview = false

    private let availableDocuments: [String]

    init(availableDocuments: [String] = []) {
        self.availableDocuments = availableDocuments
    }

    var body: some View {
        NavigationStack {
            Group {
                if showReview, let summary = generatedSummary {
                    reviewView(summary: summary)
                } else {
                    formView
                }
            }
            .navigationTitle(showReview ? "Review Summary" : "Case Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if showReview {
                        Button("Edit") { showReview = false }
                    } else {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Input Form

    private var formView: some View {
        ScrollView {
            VStack(spacing: 16) {
                infoCard

                Group {
                    InputSection(
                        title: "Current Situation",
                        placeholder: "e.g. I lost my apartment 2 weeks ago and am staying with a friend temporarily.",
                        text: $situation
                    )
                    InputSection(
                        title: "Housing Need",
                        placeholder: "e.g. I need emergency shelter and then transitional housing for 3–6 months.",
                        text: $housingNeed
                    )
                    InputSection(
                        title: "Relevant Background",
                        placeholder: "e.g. I have two children ages 4 and 7. I am employed part-time.",
                        text: $background
                    )
                    InputSection(
                        title: "Assistance Required",
                        placeholder: "e.g. Help applying for rental assistance, case manager referral, and shelter placement.",
                        text: $assistanceNeeded
                    )
                }

                if !availableDocuments.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Documents in Your Vault")
                            .font(.subheadline.bold())
                        ForEach(availableDocuments, id: \.self) { doc in
                            Label(doc, systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .havenCard()
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await generate() }
                } label: {
                    if isGenerating {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Generating summary…")
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Label("Generate Case Summary", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isGenerating || situation.isEmpty || housingNeed.isEmpty || assistanceNeeded.isEmpty)
            }
            .padding()
        }
    }

    // MARK: - Review View

    private func reviewView(summary: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Label("Review before sharing. You can edit the text below or regenerate.", systemImage: "eye.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                TextEditor(text: Binding(
                    get: { generatedSummary ?? "" },
                    set: { generatedSummary = $0 }
                ))
                .font(.subheadline)
                .padding(10)
                .frame(minHeight: 300)
                .havenCard()

                HStack(spacing: 12) {
                    Button {
                        Task { await generate() }
                    } label: {
                        Label("Regenerate", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isGenerating)

                    ShareLink(
                        item: generatedSummary ?? "",
                        subject: Text("Case Summary — Haven"),
                        message: Text("Please find my case summary below.")
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Label(
                    "This summary only shares what you entered above. No other data from your vault is included.",
                    systemImage: "lock.shield.fill"
                )
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .havenCard()
            }
            .padding()
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("What is this?", systemImage: "info.circle.fill")
                .font(.subheadline.bold())
                .foregroundColor(.blue)
            Text("This creates a short professional summary you can share with shelters, case managers, or agencies. You review and approve it before anything is shared.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .havenCard()
    }

    // MARK: - Generate

    private func generate() async {
        isGenerating = true
        errorMessage = nil
        do {
            generatedSummary = try await ClaudeService.shared.generateCaseSummary(
                situation: situation,
                housingNeed: housingNeed,
                background: background,
                availableDocuments: availableDocuments,
                assistanceNeeded: assistanceNeeded
            )
            showReview = true
        } catch {
            errorMessage = "Could not generate summary. Please check your connection and try again."
        }
        isGenerating = false
    }
}

// MARK: - Input Section

struct InputSection: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
            TextEditor(text: $text)
                .font(.subheadline)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(14)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .allowsHitTesting(false)
                        }
                    }
                )
        }
    }
}
