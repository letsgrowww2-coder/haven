import Foundation
import Combine

@MainActor
class PathwayViewModel: ObservableObject {
    @Published var steps: [HousingStep] = HousingStep.defaultPathway
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firebase = FirebaseService.shared
    private let claude = ClaudeService.shared

    var completedCount: Int { steps.filter { $0.status == .completed }.count }
    var progressFraction: Double { steps.isEmpty ? 0 : Double(completedCount) / Double(steps.count) }

    func load(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let saved = try await firebase.fetchHousingSteps(userId: userId)
            if !saved.isEmpty { steps = saved }
        } catch {
            // Fall back to default pathway — not an error the user needs to see
        }
    }

    func updateStep(_ step: HousingStep, to status: HousingStep.StepStatus, userId: String) async {
        guard let idx = steps.firstIndex(where: { $0.id == step.id }) else { return }
        steps[idx].status = status
        steps[idx].completedAt = status == .completed ? Date() : nil
        do {
            try await firebase.saveHousingSteps(steps, userId: userId)
        } catch {
            errorMessage = "Progress saved locally but not synced."
        }
    }

    func askClaude(about step: HousingStep, language: HavenUser.Language) async -> String {
        do {
            return try await claude.ask(
                "I'm working on '\(step.title)' in my housing journey. \(step.description). Can you help me understand what to do next and what documents I need?",
                context: language == .english ? nil : "Please respond in \(language.displayName)."
            )
        } catch {
            return "Could not reach AI assistant right now. Please try again."
        }
    }
}
