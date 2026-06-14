import Foundation

struct HavenUser: Codable {
    let uid: String
    var displayName: String?
    var preferredLanguage: Language
    var createdAt: Date
    var lastActiveAt: Date

    enum Language: String, CaseIterable, Codable, Identifiable {
        var id: String { rawValue }

        case english    = "en"
        case spanish    = "es"
        case chinese    = "zh"
        case hindi      = "hi"
        case arabic     = "ar"
        case french     = "fr"
        case portuguese = "pt"

        var displayName: String {
            switch self {
            case .english:    return "English"
            case .spanish:    return "Español"
            case .chinese:    return "中文"
            case .hindi:      return "हिंदी"
            case .arabic:     return "العربية"
            case .french:     return "Français"
            case .portuguese: return "Português"
            }
        }

        var isRTL: Bool { self == .arabic }
    }
}
