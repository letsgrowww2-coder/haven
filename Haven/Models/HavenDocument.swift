import Foundation

struct HavenDocument: Identifiable, Codable {
    let id: String
    var name: String
    var category: DocumentCategory
    var firebaseStoragePath: String
    var uploadedAt: Date
    var tags: [String]
    var fileSize: Int64
    var mimeType: String
    var aiSummary: String?

    enum DocumentCategory: String, CaseIterable, Codable, Identifiable {
        var id: String { rawValue }

        case id = "ID & Identity"
        case housing = "Housing"
        case medical = "Medical"
        case financial = "Financial"
        case legal = "Legal"
        case employment = "Employment"
        case benefits = "Benefits"
        case other = "Other"

        var icon: String {
            switch self {
            case .id: return "person.text.rectangle"
            case .housing: return "house"
            case .medical: return "cross.case"
            case .financial: return "dollarsign.square"
            case .legal: return "doc.text"
            case .employment: return "briefcase"
            case .benefits: return "hand.raised"
            case .other: return "folder"
            }
        }
    }
}
