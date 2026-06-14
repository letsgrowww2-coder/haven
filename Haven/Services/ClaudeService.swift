import Foundation
import CoreLocation

class ClaudeService {
    static let shared = ClaudeService()

    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-opus-4-8"

    private let systemPrompt = """
    You are the AI assistant for "Haven," a housing support application. You are a warm, knowledgeable, and supportive assistant. You can answer ANY question the user asks — about housing, benefits, documents, legal rights, mental health resources, local services, or anything else on their mind. Always respond in a helpful, conversational way. You are not limited to specific modes; treat every question as an opportunity to genuinely help the person in front of you.

    Use simple, clear, non-technical language at all times. Prioritize user privacy, dignity, and control. If something is unclear, ask a simple follow-up. Keep responses structured and actionable when helpful, or warm and conversational when the user just needs support.

    When relevant, you can also follow these specialized formats:

    1. RESOURCE FINDER (Apple Maps + location-based results)
    You are helping a user find nearby essential resources.
    Using the user's location and query, return relevant nearby services.
    Include:
    - Resource name
    - Type (shelter, food, healthcare, etc.)
    - Distance (if available)
    - Hours of operation (if known)
    - Key services offered
    - Eligibility notes (if known)
    - Why it is useful for the user
    Output format:
    Category:
    Name:
    Distance:
    Services:
    Notes:
    Keep results concise and practical.

    3. DOCUMENT UPLOAD → SIMPLE SUMMARY
    Analyze the uploaded document.
    Provide:
    - Simple explanation in plain English
    - Key important points
    - What the document is used for
    - Any deadlines or required actions
    Rules:
    - No legal jargon
    - No long paragraphs
    - Keep it easy to understand

    4. MISSING DOCUMENT DETECTOR
    Based on the user's provided documents, determine what is required for a housing or benefits application.
    Output format:
    Required Documents:
    Provided Documents:
    Missing Documents:
    Next Steps:
    Rules:
    - Be precise
    - Do not assume unprovided data
    - Focus only on essential requirements

    5. FORM EXPLAINER
    Explain this application or form section in simple language.
    Include:
    - What it is asking for
    - Why it is needed
    - Step-by-step instructions to complete it
    - Definitions of difficult words
    Keep explanations extremely simple and beginner-friendly.

    6. CASE SUMMARY GENERATOR (FOR SHARING WITH SHELTERS/AGENCIES)
    Create a short professional case summary for a housing or social service provider.
    Include:
    - Current situation
    - Housing need
    - Relevant background information
    - Documents available
    - Assistance required
    Rules:
    - Neutral tone
    - No unnecessary personal details
    - Must be user-reviewable before sharing

    7. DOCUMENT CHECKLIST / HOUSING ROADMAP
    Create a step-by-step roadmap for the user to reach stable housing or complete their application.
    Output:
    Step 1:
    Step 2:
    Step 3:
    Also include:
    - Completed steps
    - Pending steps
    - Next recommended action
    Keep it simple and linear.

    8. TRANSLATION + SIMPLIFICATION MODE
    Translate and explain the following text in [LANGUAGE].
    Include:
    - Accurate translation
    - Simple explanation of meaning
    Rules:
    - Avoid literal translation when unclear
    - Keep meaning accurate and simple

    9. SAFE SHARING GENERATOR
    Prepare a privacy-safe version of the user's information for sharing with a shelter or agency.
    Include only necessary details:
    - Identity basics
    - Housing situation
    - Needed support
    - Relevant documents
    Rules:
    - Remove sensitive or unnecessary data
    - Do not infer missing info
    - Keep tone neutral and professional

    10. RESOURCE EXPLANATION (when user is confused)
    The user is asking about a resource or service.
    Explain:
    - What it is
    - Who it helps
    - What happens when they go there
    - What to bring or expect
    Keep explanation simple and non-technical.

    11. SAFETY / CLARIFICATION MODE
    If information is missing or unclear:
    - State what is missing
    - Ask a simple follow-up question
    - Do not assume details
    - Keep tone supportive and simple.
    """

    private init() {}

    func ask(_ message: String, context: String? = nil) async throws -> String {
        let fullMessage = [context, message].compactMap { $0 }.joined(separator: "\n\n")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 2048,
            "system": systemPrompt,
            "messages": [["role": "user", "content": fullMessage]]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw ClaudeError.invalidResponse }

        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            throw ClaudeError.httpError(http.statusCode, body)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]] else {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            throw ClaudeError.parseError(body)
        }

        let text = content
            .filter { $0["type"] as? String == "text" }
            .compactMap { $0["text"] as? String }
            .joined(separator: "\n")

        guard !text.isEmpty else { throw ClaudeError.parseError("empty content array") }
        return text
    }

    func summarizeDocument(text: String, language: HavenUser.Language = .english) async throws -> String {
        let langNote = language == .english ? "" : " Please respond in \(language.displayName)."
        return try await ask("Summarize this document in simple, plain language. What does it mean? What action is needed? Are there any deadlines?\(langNote)\n\nDocument:\n\(text)")
    }

    func helpWithForm(_ formName: String, question: String, language: HavenUser.Language = .english) async throws -> String {
        let langNote = language == .english ? "" : " Please respond in \(language.displayName)."
        return try await ask("I'm filling out a \(formName) form and need help with this question: \(question)\(langNote)")
    }

    func generateCaseSummary(
        situation: String,
        housingNeed: String,
        background: String,
        availableDocuments: [String],
        assistanceNeeded: String
    ) async throws -> String {
        let docList = availableDocuments.isEmpty ? "None listed" : availableDocuments.joined(separator: ", ")
        let prompt = """
        Generate a professional case summary for a housing or social service provider using the information below. \
        Follow the Case Summary Generator instructions: neutral tone, no unnecessary personal details, structured format.

        Current Situation: \(situation)
        Housing Need: \(housingNeed)
        Relevant Background: \(background)
        Documents Available: \(docList)
        Assistance Required: \(assistanceNeeded)
        """
        return try await ask(prompt)
    }

    func identifyMissingDocuments(for purpose: String, have documents: [String]) async throws -> String {
        let list = documents.isEmpty ? "none" : documents.joined(separator: ", ")
        return try await ask("I want to \(purpose). I currently have these documents: \(list). What am I missing and where can I get each one?")
    }

    func generateRoadmap(
        goal: String,
        completedSteps: [String],
        availableDocuments: [String]
    ) async throws -> String {
        let completed = completedSteps.isEmpty ? "None yet" : completedSteps.map { "• \($0)" }.joined(separator: "\n")
        let docs = availableDocuments.isEmpty ? "None" : availableDocuments.joined(separator: ", ")
        let prompt = """
        Using the Housing Roadmap instructions, create a clear step-by-step roadmap for this goal: \(goal)

        Completed steps so far:
        \(completed)

        Documents the user currently has: \(docs)

        Output each step labeled Step 1, Step 2, etc. Then list completed steps, pending steps, and the single next recommended action.
        """
        return try await ask(prompt)
    }

    func generateSafeProfile(
        identityBasics: String,
        housingSituation: String,
        neededSupport: String,
        availableDocuments: [String]
    ) async throws -> String {
        let docs = availableDocuments.isEmpty ? "None listed" : availableDocuments.joined(separator: ", ")
        return try await ask("""
        Using the Safe Sharing Generator instructions, prepare a privacy-safe profile for sharing with a shelter or agency.

        Identity basics: \(identityBasics)
        Housing situation: \(housingSituation)
        Needed support: \(neededSupport)
        Documents available: \(docs)

        Remove any sensitive details. Keep it neutral and professional.
        """)
    }

    func explainResource(_ resource: Resource) async throws -> String {
        return try await ask("""
        Using the Resource Explanation instructions, explain this service to someone who has never used it before.

        Name: \(resource.name)
        Type: \(resource.category.rawValue)
        Description: \(resource.description)
        Hours: \(resource.hours ?? "Unknown")
        Requires ID: \(resource.requiresID ? "Yes" : "No")

        Explain: what it is, who it helps, what happens when they walk in, and what to bring.
        """)
    }

    func translate(text: String, into language: HavenUser.Language) async throws -> String {
        return try await ask("""
        Using the Translation + Simplification Mode instructions, translate and explain the following text in \(language.displayName).
        Provide an accurate translation first, then a simple plain-language explanation of what it means.

        Text to translate:
        \(text)
        """)
    }

    func findResources(query: String, near location: CLLocation?) async throws -> String {
        let resources = try await ResourceFinderService.shared.find(query: query, near: location)
        let formatted = ResourceFinderService.shared.formattedResults(
            for: query,
            resources: resources,
            near: location
        )

        let locationNote = location == nil
            ? "User location is unavailable — distances are omitted."
            : "Results are sorted by proximity to the user's current location."

        return """
        Nearby resources for: "\(query)"
        \(locationNote)

        \(formatted)
        """
    }

    enum ClaudeError: LocalizedError {
        case invalidResponse
        case parseError(String)
        case httpError(Int, String)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Network error — could not reach api.anthropic.com"
            case .parseError(let body):
                return "Parse error. Response: \(body.prefix(200))"
            case .httpError(let code, let body):
                return "API error \(code): \(body.prefix(300))"
            }
        }
    }
}
