import SwiftUI

struct PathwayView: View {
    @StateObject private var viewModel = PathwayViewModel()
    @EnvironmentObject var appState: AppState
    @State private var expandedStepId: String?
    @State private var aiResponse: String?
    @State private var aiLoadingStepId: String?
    @State private var showRoadmapSheet = false
    @State private var aiRoadmap: String?
    @State private var isGeneratingRoadmap = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    progressHeader
                    stepsList
                }
                .padding()
            }
            .navigationTitle(L10n.t(.navHousingPathway))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showRoadmapSheet = true
                    } label: {
                        Label("AI Roadmap", systemImage: "sparkles")
                            .font(.caption)
                    }
                }
            }
            .havenSOS()
            .sheet(isPresented: $showRoadmapSheet) {
                RoadmapSheet(
                    steps: viewModel.steps,
                    language: appState.preferredLanguage,
                    aiRoadmap: $aiRoadmap,
                    isGenerating: $isGeneratingRoadmap
                )
            }
            .task {
                let uid = appState.userId
                await viewModel.load(userId: uid)
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

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 14) {
            ProgressView(value: viewModel.progressFraction)
                .tint(.green)
                .scaleEffect(y: 2.5)

            HStack {
                Text("\(viewModel.completedCount) of \(viewModel.steps.count) steps complete")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(viewModel.progressFraction * 100))%")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            if viewModel.completedCount == viewModel.steps.count {
                Label("You've reached stable housing!", systemImage: "house.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .havenCard()
    }

    // MARK: - Steps List

    private var stepsList: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.steps) { step in
                StepCard(
                    step: step,
                    isExpanded: expandedStepId == step.id,
                    isAILoading: aiLoadingStepId == step.id,
                    aiResponse: expandedStepId == step.id ? aiResponse : nil,
                    onTap: {
                        withAnimation(.spring(duration: 0.25)) {
                            if expandedStepId == step.id {
                                expandedStepId = nil
                                aiResponse = nil
                            } else {
                                expandedStepId = step.id
                                aiResponse = nil
                            }
                        }
                    },
                    onStatusChange: { status in
                        Task {
                            let uid = appState.userId
                            await viewModel.updateStep(step, to: status, userId: uid)
                        }
                    },
                    onAskAI: {
                        aiLoadingStepId = step.id
                        aiResponse = nil
                        Task {
                            let response = await viewModel.askClaude(about: step, language: appState.preferredLanguage)
                            aiResponse = response
                            aiLoadingStepId = nil
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Step Card

struct StepCard: View {
    let step: HousingStep
    let isExpanded: Bool
    let isAILoading: Bool
    let aiResponse: String?
    let onTap: () -> Void
    let onStatusChange: (HousingStep.StepStatus) -> Void
    let onAskAI: () -> Void

    private var statusColor: Color {
        switch step.status {
        case .completed: return .green
        case .inProgress: return .blue
        case .blocked: return .red
        case .notStarted: return Color(.systemGray3)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(statusColor).frame(width: 28, height: 28)
                        if step.status == .completed {
                            Image(systemName: "checkmark").font(.caption.bold()).foregroundColor(.white)
                        } else {
                            Text("\(step.order)").font(.caption.bold()).foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.title).font(.subheadline.bold()).foregroundColor(.primary)
                        Text(step.status.rawValue).font(.caption).foregroundColor(statusColor)
                    }

                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Divider()

                    Text(step.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)

                    if !step.requiredDocuments.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Documents needed:").font(.caption.bold()).foregroundColor(.secondary)
                            ForEach(step.requiredDocuments, id: \.self) { doc in
                                Label(doc, systemImage: "doc.fill")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    // Status buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(HousingStep.StepStatus.allCases, id: \.self) { status in
                                Button(status.rawValue) { onStatusChange(status) }
                                    .font(.caption.bold())
                                    .buttonStyle(.bordered)
                                    .tint(step.status == status ? .blue : .gray)
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    // AI response
                    if let response = aiResponse {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("AI Guidance", systemImage: "sparkles")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                            Text(response)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(Color.blue.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal, 14)
                    } else if isAILoading {
                        HStack(spacing: 8) {
                            ProgressView().scaleEffect(0.8)
                            Text("Getting AI guidance…").font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 14)
                    }

                    Button(action: onAskAI) {
                        Label("Ask AI for guidance", systemImage: "sparkles")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(isAILoading)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(statusColor.opacity(isExpanded ? 0.4 : 0.15), lineWidth: 1.5)
        )
    }
}

// MARK: - AI Roadmap Sheet

struct RoadmapSheet: View {
    let steps: [HousingStep]
    let language: HavenUser.Language
    @Binding var aiRoadmap: String?
    @Binding var isGenerating: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var goal = ""
    @State private var errorMessage: String?

    private var completedStepTitles: [String] {
        steps.filter { $0.status == .completed }.map(\.title)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What is your housing goal?")
                            .font(.subheadline.bold())
                        TextField("e.g. Get into transitional housing within 60 days", text: $goal)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .havenCard()

                    if !completedStepTitles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Steps already completed").font(.subheadline.bold())
                            ForEach(completedStepTitles, id: \.self) { step in
                                Label(step, systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .havenCard()
                    }

                    if let roadmap = aiRoadmap {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Your Roadmap", systemImage: "map.fill")
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                            Text(roadmap)
                                .font(.subheadline)
                        }
                        .padding()
                        .havenCard()

                        ShareLink(item: roadmap, subject: Text("My Housing Roadmap")) {
                            Label("Share Roadmap", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    if let error = errorMessage {
                        Text(error).font(.caption).foregroundColor(.red)
                    }

                    Button {
                        Task { await generate() }
                    } label: {
                        if isGenerating {
                            HStack(spacing: 8) { ProgressView(); Text("Generating roadmap…") }
                                .frame(maxWidth: .infinity)
                        } else {
                            Label(aiRoadmap == nil ? "Generate My Roadmap" : "Regenerate", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isGenerating || goal.isEmpty)
                }
                .padding()
            }
            .navigationTitle("AI Housing Roadmap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func generate() async {
        isGenerating = true
        errorMessage = nil
        do {
            aiRoadmap = try await ClaudeService.shared.generateRoadmap(
                goal: goal,
                completedSteps: completedStepTitles,
                availableDocuments: []
            )
        } catch {
            errorMessage = "Could not generate roadmap. Please try again."
        }
        isGenerating = false
    }
}
