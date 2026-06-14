import SwiftUI

struct SharingView: View {
    let document: HavenDocument
    @Environment(\.dismiss) private var dismiss
    @State private var shareLink: HavenShareLink?
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var expiryHours = Constants.Sharing.defaultExpiryHours

    private let expiryOptions = [24, 48, 72, 168, 720]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Document info
                    HStack(spacing: 12) {
                        Image(systemName: document.category.icon)
                            .font(.title2)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(document.name).font(.headline)
                            Text(document.category.rawValue).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .havenCard()

                    // Expiry picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Link expires after").font(.subheadline.bold())
                        Picker("Expiry", selection: $expiryHours) {
                            ForEach(expiryOptions, id: \.self) { h in
                                Text(expiryLabel(hours: h)).tag(h)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .havenCard()

                    if let link = shareLink {
                        activeShareLink(link)
                    } else {
                        Button {
                            Task { await createLink() }
                        } label: {
                            if isCreating {
                                HStack {
                                    ProgressView()
                                    Text("Creating secure link…")
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                Label("Create Secure Link", systemImage: "lock.open.fill")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(isCreating)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Privacy notice
                    Label(
                        "Recipients can only view the document — they cannot download or share it further. You can revoke access at any time.",
                        systemImage: "info.circle"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .havenCard()
                }
                .padding()
            }
            .navigationTitle("Share Securely")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func activeShareLink(_ link: HavenShareLink) -> some View {
        VStack(spacing: 16) {
            // QR Code
            if let qr = SharingService.shared.qrCode(for: link) {
                Image(uiImage: qr)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 4)
            }

            // Access code
            VStack(spacing: 6) {
                Text("Access Code").font(.caption).foregroundColor(.secondary)
                Text(link.accessCode)
                    .font(.system(.title2, design: .monospaced).bold())
                    .tracking(4)
            }

            // Expiry
            HStack {
                Image(systemName: "clock").foregroundColor(.orange)
                Text("Expires \(link.expiresAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Share sheet
            if let url = link.shareURL {
                ShareLink(item: url, subject: Text("Secure document: \(link.documentName)"),
                          message: Text("Access code: \(link.accessCode)")) {
                    Label("Share Link", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            // Revoke
            Button(role: .destructive) {
                Task {
                    try? await SharingService.shared.revokeLink(link)
                    shareLink = nil
                }
            } label: {
                Label("Revoke Access", systemImage: "xmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        .havenCard()
    }

    private func createLink() async {
        isCreating = true
        errorMessage = nil
        do {
            shareLink = try await SharingService.shared.createShareLink(
                for: document, expiresInHours: expiryHours
            )
        } catch {
            errorMessage = "Could not create share link. Make sure Firebase is configured."
        }
        isCreating = false
    }

    private func expiryLabel(hours: Int) -> String {
        if hours < 24 { return "\(hours)h" }
        let days = hours / 24
        return days == 1 ? "1 day" : "\(days) days"
    }
}
