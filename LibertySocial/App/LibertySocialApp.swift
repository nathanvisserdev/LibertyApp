//
//  LibertySocialApp.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-02.
//

import SwiftUI

@main
struct LibertySocialApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isAuthenticated {
                    FeedView() // replace with your actual authenticated root
                } else {
                    LoginView()
                }
            }
            .environmentObject(session)
            .onAppear { session.refresh() } // silent re-auth on launch
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                session.refresh()            // re-check on foreground
            }
        }
    }
}
