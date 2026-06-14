import SwiftUI

struct SafeProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var identityBasics = ""
    @State private var housingSituation = ""
    @State private var neededSupport = ""
    @State private var result: String?
    @State private var isGenerating = false
    @State private var errorMessage: String?

    let availableDocuments: [String]

    init(availableDocuments: [String] = []) {
        self.availableDocuments = availableDocuments
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    infoCard

                    if let result {
                        reviewCard(result)
                    } else {
                        formFields
                    }

                    if let error = errorMessage {
                        Text(error).font(.caption).foregroundColor(.red)
                    }

                    actionButton
                }
                .padding()
            }
            .navigationTitle(result == nil ? "Safe Profile" : "Review Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if result != nil {
                        Button("Edit") { result = nil }
                    } else {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Info card

    private var infoCard: some View {
        Label("This creates a minimal, privacy-safe profile with only what a shelter or agency needs to help you. You review it before anything is shared.", systemImage: "lock.shield.fill")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .havenCard()
    }

    // MARK: - Form

    private var formFields: some View {
        VStack(spacing: 16) {
            InputSection(
                title: "Identity Basics",
                placeholder: "e.g. Adult female, age 34, with two children (ages 4 and 7).",
                text: $identityBasics
            )
            InputSection(
                title: "Housing Situation",
                placeholder: "e.g. Lost housing 3 weeks ago, currently staying temporarily with a friend.",
                text: $housingSituation
            )
            InputSection(
                title: "Needed Support",
                placeholder: "e.g. Emergency shelter placement, rental assistance application, food access.",
                text: $neededSupport
            )

            if !availableDocuments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Documents in your vault").font(.subheadline.bold())
                    ForEach(availableDocuments, id: \.self) { doc in
                        Label(doc, systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .havenCard()
            }
        }
    }

    // MARK: - Review card

    private func reviewCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Privacy-Safe Profile", systemImage: "checkmark.shield.fill")
                .font(.subheadline.bold())
                .foregroundColor(.green)

            Text("Review below. You can edit the text or regenerate before sharing.")
                .font(.caption)
                .foregroundColor(.secondary)

            TextEditor(text: Binding(
                get: { result ?? "" },
                set: { result = $0 }
            ))
            .font(.subheadline)
            .frame(minHeight: 220)
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            ShareLink(
                item: result ?? "",
                subject: Text("Profile — Haven"),
                message: Text("Please find my profile below.")
            ) {
                Label("Share Profile", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Label("Only what you typed above is shared. Nothing else from your vault is included.", systemImage: "info.circle")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .havenCard()
    }

    // MARK: - Action button

    private var actionButton: some View {
        Button {
            Task { await generate() }
        } label: {
            if isGenerating {
                HStack(spacing: 8) { ProgressView(); Text("Generating…") }
                    .frame(maxWidth: .infinity)
            } else {
                Label(result == nil ? "Generate Safe Profile" : "Regenerate", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isGenerating || identityBasics.isEmpty || housingSituation.isEmpty || neededSupport.isEmpty)
    }

    private func generate() async {
        isGenerating = true
        errorMessage = nil
        do {
            result = try await ClaudeService.shared.generateSafeProfile(
                identityBasics: identityBasics,
                housingSituation: housingSituation,
                neededSupport: neededSupport,
                availableDocuments: availableDocuments
            )
        } catch {
            errorMessage = "Could not generate profile. Please try again."
        }
        isGenerating = false
    }
}
