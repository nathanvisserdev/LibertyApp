//
//  LibertySocialApp.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-02.
//

import SwiftUI

@main
struct LibertySocialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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
            .onAppear { 
                Task { await session.refresh() }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task { await session.refresh() }
            }
        }
    }
}
