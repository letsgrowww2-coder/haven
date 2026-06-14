import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSupportGroups = false
    @State private var showSignOutConfirm = false

    private var initials: String {
        let parts = appState.profileName.split(separator: " ")
        let letters = parts.prefix(2).compactMap(\.first).map(String.init)
        return letters.joined().uppercased()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    avatarHeader
                    infoSection
                    locationSection
                    supportGroupBanner
                    signOutButton
                    Spacer(minLength: 24)
                }
                .padding()
            }
            .navigationTitle(L10n.t(.navMyProfile))
            .navigationBarTitleDisplayMode(.large)
            .havenSOS()
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $showSupportGroups) {
                SupportGroupView()
                    .environmentObject(appState)
            }
            .confirmationDialog("Sign Out", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { appState.signOut() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need to log in again to access Haven.")
            }
        }
    }

    // MARK: - Avatar + Name

    private var avatarHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 88, height: 88)

                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(appState.profileName)
                .font(.title2.bold())

            if !appState.profileEmail.isEmpty {
                Text(appState.profileEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Home status badge
            if !appState.profileHomeStatus.isEmpty {
                Text(appState.profileHomeStatus)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(homeStatusColor)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Info rows

    private var infoSection: some View {
        VStack(spacing: 0) {
            profileRow(icon: "phone.fill", color: .green, label: L10n.t(.phone), value: appState.profilePhone)
            Divider().padding(.leading, 52)
            profileRow(icon: "briefcase.fill", color: .orange, label: L10n.t(.occupation), value: appState.profileOccupation)
            Divider().padding(.leading, 52)
            profileRow(icon: "house.fill", color: .blue, label: L10n.t(.homeStatus), value: appState.profileHomeStatus)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var locationSection: some View {
        VStack(spacing: 0) {
            profileRow(icon: "location.fill", color: .red, label: L10n.t(.area), value: appState.profilePrimaryCity)
            if appState.primaryLocation != nil {
                Divider().padding(.leading, 52)
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .frame(width: 28, height: 28)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Circle())
                        .padding(.leading, 12)
                    Text(L10n.t(.showingNearby))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 14)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Support Group Banner

    private var supportGroupBanner: some View {
        Button {
            showSupportGroups = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.3.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t(.findSupportGroup))
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text(L10n.t(.supportGroupSub))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.purple)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.25), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button(role: .destructive) {
            showSignOutConfirm = true
        } label: {
            Label(L10n.t(.signOut), systemImage: "rectangle.portrait.and.arrow.right")
                .frame(maxWidth: .infinity)
                .font(.subheadline.bold())
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .tint(.red)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func profileRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(Circle())
                .padding(.leading, 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value.isEmpty ? "—" : value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.vertical, 14)
    }

    private var homeStatusColor: Color {
        switch appState.profileHomeStatus {
        case "Stably Housed": return .green
        case "At Risk of Losing Housing": return .orange
        case "In a Shelter", "Living Outdoors or in Vehicle": return .red
        case "In Transitional Housing", "Staying with Others": return .blue
        default: return .gray
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
