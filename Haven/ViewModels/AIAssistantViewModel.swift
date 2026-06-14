import Foundation
import Combine

@MainActor
class AIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var selectedLanguage: HavenUser.Language = .english

    private let claude = ClaudeService.shared
    private let locationService = LocationService.shared

    private let resourceQueryHints = [
        "find", "nearby", "near me", "closest", "where", "shelter", "food",
        "healthcare", "clinic", "legal", "mental", "employment", "resource"
    ]

    struct ChatMessage: Identifiable {
        let id = UUID()
        let role: Role
        let content: String
        let timestamp = Date()

        enum Role { case user, assistant }
    }

    func send() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))

        isLoading = true
        defer { isLoading = false }

        do {
            let reply: String
            if isResourceQuery(text) {
                reply = try await claude.findResources(
                    query: text,
                    near: locationService.currentLocation
                )
            } else {
                let context = selectedLanguage != .english
                    ? "Please respond in \(selectedLanguage.displayName)."
                    : nil
                reply = try await claude.ask(text, context: context)
            }
            messages.append(ChatMessage(role: .assistant, content: reply))
        } catch {
            messages.append(ChatMessage(role: .assistant, content: "Error: \(error.localizedDescription)"))
        }
    }

    func clearHistory() {
        messages.removeAll()
    }

    private func isResourceQuery(_ text: String) -> Bool {
        let normalized = text.lowercased()
        return resourceQueryHints.contains { normalized.contains($0) }
    }
}
