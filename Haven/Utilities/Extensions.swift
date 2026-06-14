import SwiftUI
import Foundation

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension View {
    func havenCard() -> some View {
        self
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// Adds a red SOS pill to the leading side of the navigation bar.
    func havenSOS() -> some View {
        modifier(SOSToolbarModifier())
    }
}

// MARK: - SOS Toolbar Modifier

struct SOSToolbarModifier: ViewModifier {
    @State private var showEmergency = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showEmergency = true
                    } label: {
                        Text("SOS")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .shadow(color: .red.opacity(0.35), radius: 3)
                    }
                    .accessibilityLabel("Emergency help")
                }
            }
            .fullScreenCover(isPresented: $showEmergency) {
                EmergencyView()
            }
    }
}
