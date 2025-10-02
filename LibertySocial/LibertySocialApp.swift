//
//  LibertySocialApp.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-02.
//

import SwiftUI
import SwiftData

@main
struct LibertySocialApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // ContentView()
            LoginPage()
        }
        .modelContainer(sharedModelContainer)
    }
}
