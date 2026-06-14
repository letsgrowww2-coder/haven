import SwiftUI

struct SupportGroup: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let categoryIcon: String
    let categoryColor: Color
    let description: String
    let phone: String?
    let website: String?
    let howToJoin: String
    let isNational: Bool
}

private let allGroups: [SupportGroup] = [
    SupportGroup(
        name: "211 Helpline",
        category: "Housing & Basic Needs",
        categoryIcon: "house.fill",
        categoryColor: .blue,
        description: "Free referral service connecting you to local shelters, food, utilities, mental health services, and more in your area.",
        phone: "211",
        website: "https://www.211.org",
        howToJoin: "Simply call 2-1-1 or text your ZIP code to 898-211. A trained specialist will connect you with services nearby. Available 24/7.",
        isNational: true
    ),
    SupportGroup(
        name: "HUD Housing Counseling",
        category: "Housing",
        categoryIcon: "building.2.fill",
        categoryColor: .blue,
        description: "Government-approved counselors who help with rental assistance, foreclosure prevention, and navigating housing programs like Section 8.",
        phone: "1-800-569-4287",
        website: "https://www.hud.gov/findacounselor",
        howToJoin: "Call the HUD hotline or visit their website to find a free, HUD-approved housing counselor near you. Appointments available by phone or in person.",
        isNational: true
    ),
    SupportGroup(
        name: "National Alliance on Mental Illness (NAMI)",
        category: "Mental Health",
        categoryIcon: "brain.head.profile",
        categoryColor: .green,
        description: "Peer-led support groups for people living with mental illness and their families. Free, confidential groups meet weekly in most cities.",
        phone: "1-800-950-6264",
        website: "https://www.nami.org/Support-Education/Support-Groups",
        howToJoin: "Call NAMI or visit their website to find a local NAMI Connection Recovery Support Group. No referral needed — show up, no registration required.",
        isNational: true
    ),
    SupportGroup(
        name: "SAMHSA National Helpline",
        category: "Mental Health & Substance Use",
        categoryIcon: "heart.fill",
        categoryColor: .purple,
        description: "Free, confidential treatment referral and information service for individuals and families facing mental health or substance use disorders.",
        phone: "1-800-662-4357",
        website: "https://www.samhsa.gov/find-help/national-helpline",
        howToJoin: "Call 1-800-662-HELP (4357) any time, 24/7, 365 days a year. Bilingual English/Spanish. They will connect you to local treatment facilities and support groups.",
        isNational: true
    ),
    SupportGroup(
        name: "Crisis Text Line",
        category: "Crisis Support",
        categoryIcon: "message.fill",
        categoryColor: .orange,
        description: "Free, 24/7 mental health text support with trained crisis counselors. Confidential and immediately available.",
        phone: nil,
        website: "https://www.crisistextline.org",
        howToJoin: "Text HOME to 741741 from anywhere in the USA. You'll be connected to a trained Crisis Counselor within minutes.",
        isNational: true
    ),
    SupportGroup(
        name: "National Domestic Violence Hotline",
        category: "Domestic Violence & Safety",
        categoryIcon: "shield.fill",
        categoryColor: .red,
        description: "Confidential support for anyone affected by relationship abuse. Helps with safety planning, local shelter, and legal resources.",
        phone: "1-800-799-7233",
        website: "https://www.thehotline.org",
        howToJoin: "Call 1-800-799-SAFE (7233) or text START to 88788. Chat available at thehotline.org. Available 24/7 in more than 200 languages.",
        isNational: true
    ),
    SupportGroup(
        name: "National Alliance to End Homelessness",
        category: "Housing",
        categoryIcon: "house.circle.fill",
        categoryColor: .teal,
        description: "Advocacy and direct resources to help individuals and families experiencing homelessness access housing and stability services.",
        phone: nil,
        website: "https://endhomelessness.org/find-help",
        howToJoin: "Visit their website to find a Continuum of Care (CoC) near you — the local network of housing organizations in your region. Your CoC is your main gateway to subsidized housing programs.",
        isNational: true
    ),
    SupportGroup(
        name: "Salvation Army",
        category: "Shelter, Food & Support",
        categoryIcon: "cross.fill",
        categoryColor: .red,
        description: "Local emergency shelters, food pantries, disaster relief, and case management for individuals and families in crisis.",
        phone: "1-800-725-2769",
        website: "https://www.salvationarmyusa.org",
        howToJoin: "Call their hotline or find your local Salvation Army at their website. Walk-in services vary by location — call ahead for shelter bed availability.",
        isNational: true
    ),
    SupportGroup(
        name: "Veterans Crisis Line",
        category: "Veterans Support",
        categoryIcon: "star.fill",
        categoryColor: Color(red: 0.1, green: 0.3, blue: 0.6),
        description: "Confidential crisis support for veterans, service members, and their families. Staffed by qualified responders, many of whom are veterans themselves.",
        phone: "988 (Press 1)",
        website: "https://www.veteranscrisisline.net",
        howToJoin: "Dial 988 and press 1, or text 838255. Chat available online. Available 24/7.",
        isNational: true
    ),
    SupportGroup(
        name: "PATH (Projects for Assistance in Transition from Homelessness)",
        category: "Housing & Mental Health",
        categoryIcon: "figure.walk",
        categoryColor: .indigo,
        description: "Federally funded program that outreaches to people experiencing homelessness with mental illness, offering case management, housing assistance, and treatment referrals.",
        phone: nil,
        website: "https://pathprogram.samhsa.gov",
        howToJoin: "Contact your local PATH grantee via SAMHSA's website. An outreach worker can come to you — you don't need to go to an office to start.",
        isNational: true
    )
]

struct SupportGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var selectedGroup: SupportGroup?
    @State private var selectedCategory: String = "All"

    private var categories: [String] {
        ["All"] + Array(Set(allGroups.map(\.category))).sorted()
    }

    private var filtered: [SupportGroup] {
        selectedCategory == "All" ? allGroups : allGroups.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button(cat) {
                                selectedCategory = cat
                            }
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedCategory == cat ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedCategory == cat ? .white : .primary)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(Color(.systemGroupedBackground))

                Divider()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { group in
                            SupportGroupCard(group: group)
                                .onTapGesture { selectedGroup = group }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Support Groups")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $selectedGroup) { group in
                SupportGroupDetailView(group: group)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: - Card

struct SupportGroupCard: View {
    let group: SupportGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: group.categoryIcon)
                    .font(.title3)
                    .foregroundColor(group.categoryColor)
                    .frame(width: 44, height: 44)
                    .background(group.categoryColor.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(.subheadline.bold())

                    HStack(spacing: 4) {
                        Text(group.category)
                            .font(.caption)
                            .foregroundColor(group.categoryColor)
                        if group.isNational {
                            Text("· National")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(group.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if let phone = group.phone {
                Label(phone, systemImage: "phone.fill")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Detail

struct SupportGroupDetailView: View {
    let group: SupportGroup
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero
                    HStack(spacing: 14) {
                        Image(systemName: group.categoryIcon)
                            .font(.largeTitle)
                            .foregroundColor(group.categoryColor)
                            .frame(width: 64, height: 64)
                            .background(group.categoryColor.opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(group.name)
                                .font(.headline)
                            Text(group.category)
                                .font(.subheadline)
                                .foregroundColor(group.categoryColor)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.subheadline.bold())
                        Text(group.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // How to join
                    VStack(alignment: .leading, spacing: 8) {
                        Label("How to Apply / Join", systemImage: "arrow.right.circle.fill")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                        Text(group.howToJoin)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Contact buttons
                    VStack(spacing: 10) {
                        if let phone = group.phone {
                            Button {
                                let cleaned = phone.filter { $0.isNumber }
                                if let url = URL(string: "tel://\(cleaned)") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Label("Call \(phone)", systemImage: "phone.fill")
                                    .frame(maxWidth: .infinity)
                                    .font(.headline)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(.green)
                        }

                        if let website = group.website, let url = URL(string: website) {
                            Link(destination: url) {
                                Label("Visit Website", systemImage: "globe")
                                    .frame(maxWidth: .infinity)
                                    .font(.headline)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(group.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
