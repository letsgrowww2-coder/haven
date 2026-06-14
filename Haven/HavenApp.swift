//
//  HavenApp.swift
//  Haven
//
//  Created by Reyaansh Bansal on 6/13/26.
//

import SwiftUI

@main
struct HavenApp: App {
    @StateObject private var appState = AppState()

    init() {
        // TODO: Uncomment after adding Firebase package via File > Add Package Dependencies
        // FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if appState.isAuthenticated {
                ContentView()
                    .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
    }
}
