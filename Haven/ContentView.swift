import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            MapView()
                .tabItem { Label(L10n.t(.tabFindHelp), systemImage: "map.fill") }

            VaultView()
                .tabItem { Label(L10n.t(.tabMyDocs), systemImage: "lock.shield.fill") }

            PathwayView()
                .tabItem { Label(L10n.t(.tabPathway), systemImage: "signpost.right.fill") }

            AIAssistantView()
                .tabItem { Label(L10n.t(.tabAskAI), systemImage: "bubble.left.and.bubble.right.fill") }

            ProfileView()
                .tabItem { Label(L10n.t(.tabProfile), systemImage: "person.circle.fill") }
        }
        .tint(.blue)
        .environment(\.layoutDirection, appState.preferredLanguage.isRTL ? .rightToLeft : .leftToRight)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
