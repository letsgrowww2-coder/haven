import Foundation
import CoreImage
import UIKit

class SharingService {
    static let shared = SharingService()
    private init() {}

    func createShareLink(
        for document: HavenDocument,
        expiresInHours: Int = Constants.Sharing.defaultExpiryHours,
        maxViews: Int? = nil
    ) async throws -> HavenShareLink {
        let link = HavenShareLink(
            id: UUID().uuidString,
            documentId: document.id,
            documentName: document.name,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(TimeInterval(expiresInHours * 3600)),
            accessCode: generateAccessCode(),
            viewCount: 0,
            maxViews: maxViews,
            isRevoked: false
        )
        try await FirebaseService.shared.saveShareLink(link)
        return link
    }

    func revokeLink(_ link: HavenShareLink) async throws {
        try await FirebaseService.shared.revokeShareLink(link.id)
    }

    func qrCode(for link: HavenShareLink) -> UIImage? {
        guard let url = link.shareURL,
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(url.absoluteString.data(using: .utf8), forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        guard let ci = filter.outputImage else { return nil }
        let scaled = ci.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        return UIImage(ciImage: scaled)
    }

    private func generateAccessCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }
}
