import Foundation
import CoreLocation

/// Location- and query-based resource search with structured output for users.
class ResourceFinderService {
    static let shared = ResourceFinderService()

    private init() {}

    private let queryKeywords: [ResourceCategory: [String]] = [
        .shelter: ["shelter", "housing", "bed", "overnight", "emergency stay", "homeless"],
        .food: ["food", "meal", "pantry", "groceries", "hungry", "eat", "kitchen"],
        .healthcare: ["health", "doctor", "clinic", "medical", "dental", "care"],
        .legal: ["legal", "lawyer", "eviction", "court", "attorney"],
        .mentalHealth: ["mental", "counseling", "therapy", "crisis", "depression", "anxiety"],
        .employment: ["job", "work", "employment", "resume", "career"],
        .clothing: ["clothes", "clothing", "wardrobe"],
        .hygiene: ["shower", "hygiene", "laundry", "soap"],
        .financial: ["money", "financial", "benefits", "cash aid", "rent help"],
        .childcare: ["child", "childcare", "daycare", "kids"]
    ]

    func matchingCategories(for query: String) -> Set<ResourceCategory> {
        let normalized = query.lowercased()
        var matches = Set<ResourceCategory>()

        for (category, keywords) in queryKeywords {
            if keywords.contains(where: { normalized.contains($0) }) {
                matches.insert(category)
            }
        }

        if matches.isEmpty, let direct = ResourceCategory.allCases.first(where: { normalized.contains($0.rawValue.lowercased()) }) {
            matches.insert(direct)
        }

        return matches
    }

    func filter(query: String, resources: [Resource]) -> [Resource] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return resources }

        let normalized = trimmed.lowercased()
        let categories = matchingCategories(for: trimmed)

        return resources.filter { resource in
            if categories.contains(resource.category) { return true }
            if resource.name.lowercased().contains(normalized) { return true }
            if resource.description.lowercased().contains(normalized) { return true }
            if resource.address.lowercased().contains(normalized) { return true }
            return false
        }
    }

    func find(query: String, near location: CLLocation?, limit: Int = 5) async throws -> [Resource] {
        let all = try await ResourceService.shared.fetchNearbyResources(
            coordinate: location?.coordinate,
            radiusMeters: Constants.Map.defaultSearchRadiusMeters
        )
        let matched = filter(query: query, resources: all)
        return Array(matched.prefix(limit))
    }

    func formattedResults(for query: String, resources: [Resource], near location: CLLocation?) -> String {
        guard !resources.isEmpty else {
            return "No nearby resources matched \"\(query)\". Try a broader term like food, shelter, or healthcare, or call 211 for live referrals."
        }

        return resources.enumerated().map { index, resource in
            resource.finderFormatted(from: location, query: query, index: index + 1)
        }.joined(separator: "\n\n---\n\n")
    }
}
