import Foundation

struct HavenShareLink: Identifiable, Codable {
    let id: String
    let documentId: String
    let documentName: String
    let createdAt: Date
    let expiresAt: Date
    let accessCode: String
    var viewCount: Int
    let maxViews: Int?
    var isRevoked: Bool

    var isExpired: Bool { Date() > expiresAt }
    var isActive: Bool { !isRevoked && !isExpired }

    var shareURL: URL? {
        URL(string: "https://haven.app/share/\(id)?code=\(accessCode)")
    }
}
