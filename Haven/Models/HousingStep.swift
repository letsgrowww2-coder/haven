import Foundation

struct HousingStep: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let order: Int
    var status: StepStatus
    var completedAt: Date?
    var notes: String?
    let requiredDocuments: [String]

    enum StepStatus: String, CaseIterable, Codable {
        case notStarted = "Not Started"
        case inProgress = "In Progress"
        case completed = "Completed"
        case blocked = "Blocked"
    }

    static let defaultPathway: [HousingStep] = [
        HousingStep(id: "1", title: "Emergency Shelter", description: "Secure immediate safe shelter for tonight. Call 211 or use the Find Help map.", order: 1, status: .notStarted, requiredDocuments: []),
        HousingStep(id: "2", title: "Gather ID Documents", description: "Collect birth certificate, Social Security card, and state-issued photo ID. These are required for almost every housing program.", order: 2, status: .notStarted, requiredDocuments: ["Birth Certificate", "Social Security Card"]),
        HousingStep(id: "3", title: "Apply for Benefits", description: "Apply for SNAP (food stamps), Medicaid, and emergency rental assistance. Ask AI to help fill out forms.", order: 3, status: .notStarted, requiredDocuments: ["State ID", "Proof of Income"]),
        HousingStep(id: "4", title: "Connect with Case Manager", description: "A housing case manager guides you through the system and advocates for you. Ask a local shelter or legal aid office for a referral.", order: 4, status: .notStarted, requiredDocuments: []),
        HousingStep(id: "5", title: "Search for Housing", description: "Look for income-appropriate housing options: Section 8 vouchers, transitional housing, and affordable units.", order: 5, status: .notStarted, requiredDocuments: ["State ID", "Income Proof", "References"]),
        HousingStep(id: "6", title: "Submit Applications", description: "Apply to housing programs. Use AI Assistant to help understand application requirements.", order: 6, status: .notStarted, requiredDocuments: ["Completed Application", "All Required Documents"]),
        HousingStep(id: "7", title: "Stable Housing", description: "Move into your new home. Keep copies of your lease and important documents in your Vault.", order: 7, status: .notStarted, requiredDocuments: [])
    ]
}
