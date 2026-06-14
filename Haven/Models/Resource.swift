import Foundation
import CoreLocation

struct Resource: Identifiable, Codable {
    let id: String
    let name: String
    let category: ResourceCategory
    let address: String
    let latitude: Double
    let longitude: Double
    let phone: String?
    let hours: String?
    let description: String
    let languages: [String]
    let requiresID: Bool
    let isVerified: Bool
    let lastUpdated: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func distance(from location: CLLocation) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: location)
    }

    func distanceDisplay(from location: CLLocation?) -> String? {
        guard let location else { return nil }
        let meters = distance(from: location)
        if meters < 1609 {
            return String(format: "%.0f ft away", meters * 3.28084)
        }
        return String(format: "%.1f mi away", meters / 1609.34)
    }

    var eligibilityNotes: String {
        var notes: [String] = []
        notes.append(requiresID ? "ID required" : "No ID required")
        if !languages.isEmpty {
            notes.append("Languages: \(languages.joined(separator: ", "))")
        }
        if isVerified {
            notes.append("Verified resource")
        }
        return notes.joined(separator: ". ")
    }

    func whyUseful(for query: String) -> String {
        let normalized = query.lowercased()
        switch category {
        case .shelter:
            return normalized.contains("family") || normalized.contains("child")
                ? "Offers emergency shelter with meals for families."
                : "Closest verified shelter option for immediate overnight help."
        case .food:
            return "Provides free meals with low barriers to access."
        case .healthcare:
            return "Free or low-cost care without requiring insurance."
        case .legal:
            return "Can help with housing-related legal issues like eviction."
        case .mentalHealth:
            return "Offers counseling and crisis support in a safe setting."
        case .employment:
            return "Helps with job search, resumes, and work readiness."
        case .clothing:
            return "Free clothing for daily needs and weather protection."
        case .hygiene:
            return "Access to showers, laundry, or hygiene supplies."
        case .financial:
            return "May help with rent, benefits, or emergency cash aid."
        case .childcare:
            return "Supports parents with childcare while they seek stability."
        }
    }

    func finderFormatted(from location: CLLocation?, query: String, index: Int? = nil) -> String {
        var lines: [String] = []
        if let index {
            lines.append("Result \(index)")
        }
        lines.append("Category: \(category.rawValue)")
        lines.append("Name: \(name)")
        if let distance = distanceDisplay(from: location) {
            lines.append("Distance: \(distance)")
        }
        lines.append("Services: \(description)")
        var notes: [String] = []
        if let hours {
            notes.append("Hours: \(hours)")
        }
        notes.append(eligibilityNotes)
        notes.append("Why useful: \(whyUseful(for: query))")
        lines.append("Notes: \(notes.joined(separator: ". "))")
        return lines.joined(separator: "\n")
    }
}

enum ResourceCategory: String, CaseIterable, Codable {
    case shelter = "Shelter"
    case food = "Food"
    case healthcare = "Healthcare"
    case legal = "Legal Aid"
    case mentalHealth = "Mental Health"
    case employment = "Employment"
    case clothing = "Clothing"
    case hygiene = "Hygiene"
    case financial = "Financial Aid"
    case childcare = "Childcare"

    var icon: String {
        switch self {
        case .shelter: return "house.fill"
        case .food: return "fork.knife"
        case .healthcare: return "cross.fill"
        case .legal: return "scale.3d"
        case .mentalHealth: return "brain.head.profile"
        case .employment: return "briefcase.fill"
        case .clothing: return "tshirt.fill"
        case .hygiene: return "drop.fill"
        case .financial: return "dollarsign.circle.fill"
        case .childcare: return "figure.2.and.child.holdinghands"
        }
    }

    var colorHex: String {
        switch self {
        case .shelter: return "#4A90D9"
        case .food: return "#F5A623"
        case .healthcare: return "#D0021B"
        case .legal: return "#7B68EE"
        case .mentalHealth: return "#50C878"
        case .employment: return "#FF6B6B"
        case .clothing: return "#FFD700"
        case .hygiene: return "#87CEEB"
        case .financial: return "#32CD32"
        case .childcare: return "#FF69B4"
        }
    }
}

// MARK: - Sample data for UI testing before Firebase is wired up
extension Resource {
    static let sampleData: [Resource] = [
        Resource(id: "1", name: "City Family Shelter", category: .shelter,
                 address: "123 Main St, San Francisco, CA 94102",
                 latitude: 37.7749, longitude: -122.4194,
                 phone: "415-555-0100", hours: "Open 24/7",
                 description: "Emergency shelter for families with children. Meals included.",
                 languages: ["en", "es"], requiresID: false, isVerified: true,
                 lastUpdated: Date()),
        Resource(id: "2", name: "St. Anthony's Food Program", category: .food,
                 address: "150 Golden Gate Ave, San Francisco, CA 94102",
                 latitude: 37.7803, longitude: -122.4169,
                 phone: "415-555-0200", hours: "Mon–Fri 11am–1pm",
                 description: "Free hot meals served daily. No ID required.",
                 languages: ["en", "es", "zh"], requiresID: false, isVerified: true,
                 lastUpdated: Date()),
        Resource(id: "3", name: "Tenderloin Health Clinic", category: .healthcare,
                 address: "311 Turk St, San Francisco, CA 94102",
                 latitude: 37.7826, longitude: -122.4148,
                 phone: "415-555-0300", hours: "Mon–Fri 8am–5pm",
                 description: "Free primary care, dental, and mental health services.",
                 languages: ["en", "es", "vi"], requiresID: false, isVerified: true,
                 lastUpdated: Date()),
        Resource(id: "4", name: "Bay Area Legal Aid", category: .legal,
                 address: "1735 Telegraph Ave, Oakland, CA 94612",
                 latitude: 37.8074, longitude: -122.2669,
                 phone: "510-555-0400", hours: "Mon–Fri 9am–4pm",
                 description: "Free legal help for housing and eviction cases.",
                 languages: ["en", "es"], requiresID: true, isVerified: true,
                 lastUpdated: Date()),
        Resource(id: "5", name: "Castro Mission Health Center", category: .mentalHealth,
                 address: "3850 17th St, San Francisco, CA 94114",
                 latitude: 37.7621, longitude: -122.4297,
                 phone: "415-555-0500", hours: "Mon–Thu 8am–6pm",
                 description: "Mental health counseling, crisis intervention, and peer support.",
                 languages: ["en", "es"], requiresID: false, isVerified: true,
                 lastUpdated: Date())
    ]
}
