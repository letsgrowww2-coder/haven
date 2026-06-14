import SwiftUI

struct HelpMeNowButton: View {
    @State private var showEmergency = false

    var body: some View {
        Button { showEmergency = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "sos")
                    .font(.system(size: 18, weight: .heavy))
                Text("HELP ME NOW")
                    .font(.system(size: 15, weight: .heavy))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red)
            .clipShape(Capsule())
            .shadow(color: .red.opacity(0.45), radius: 8, y: 4)
        }
        .padding(.horizontal, 20)
        .accessibilityLabel("Emergency help")
        .accessibilityHint("Opens immediate crisis support and nearby shelter finder")
        .fullScreenCover(isPresented: $showEmergency) {
            EmergencyView()
        }
    }
}

// MARK: - Emergency Full-Screen View

struct EmergencyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mapVM = MapViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    crisisCallsSection
                    Divider()
                    nearestSheltersSection
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Emergency Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .font(.body.bold())
                }
            }
        }
        .task {
            LocationService.shared.requestLocation()
            await mapVM.loadResources()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "hands.and.sparkles.fill")
                .font(.system(size: 56))
                .foregroundColor(.red)
                .padding(.top, 8)

            Text("You are not alone.")
                .font(.title.bold())

            Text("Help is available right now, 24 hours a day.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var crisisCallsSection: some View {
        VStack(spacing: 12) {
            Text("Immediate Support")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            EmergencyActionRow(
                title: "Call 211",
                subtitle: "Free housing & social service referrals — 24/7",
                icon: "phone.fill", color: .blue
            ) { call("211") }

            EmergencyActionRow(
                title: "Call 988",
                subtitle: "Suicide & Crisis Lifeline — 24/7",
                icon: "heart.fill", color: .purple
            ) { call("988") }

            EmergencyActionRow(
                title: "Text HOME to 741741",
                subtitle: "Crisis Text Line — free 24/7 support",
                icon: "message.fill", color: .green
            ) { text(number: "741741", body: "HOME") }
        }
    }

    private var nearestSheltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearest Shelters")
                .font(.headline)

            if mapVM.isLoading {
                HStack {
                    ProgressView()
                    Text("Finding shelters near you…")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                let shelters = mapVM.resources.filter { $0.category == .shelter }.prefix(3)
                if shelters.isEmpty {
                    Text("No shelters found. Call 211 for a referral.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(shelters)) { shelter in
                        ShelterEmergencyRow(shelter: shelter) {
                            mapVM.navigateTo(shelter)
                        }
                    }
                }
            }
        }
    }

    private func call(_ number: String) {
        guard let url = URL(string: "tel://\(number)") else { return }
        UIApplication.shared.open(url)
    }

    private func text(number: String, body: String) {
        let encoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? body
        guard let url = URL(string: "sms:\(number)&body=\(encoded)") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Supporting Views

struct EmergencyActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline).foregroundColor(.primary)
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct ShelterEmergencyRow: View {
    let shelter: Resource
    let onNavigate: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(shelter.name).font(.subheadline.bold())
                Text(shelter.address).font(.caption).foregroundColor(.secondary)
                if let hours = shelter.hours {
                    Text(hours).font(.caption).foregroundColor(.secondary)
                }
                if !shelter.requiresID {
                    Label("No ID required", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            Spacer()
            Button("Navigate", action: onNavigate)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
