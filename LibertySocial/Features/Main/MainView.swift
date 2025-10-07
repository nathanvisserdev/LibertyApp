//
//  MainView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import SwiftUI

struct MainView: View {
    @StateObject private var vm = MainViewModel()
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(vm.welcomeMessage)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("You’re signed in successfully.")
                    .foregroundStyle(.secondary)

                Button("Log out") {
                    vm.logout(using: session)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Home")
            .onAppear { vm.refreshGreeting() }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(SessionStore())
}


