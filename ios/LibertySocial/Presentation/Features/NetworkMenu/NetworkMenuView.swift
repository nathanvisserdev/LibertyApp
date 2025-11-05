//
//  NetworkMenuView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import SwiftUI

struct NetworkMenuView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: NetworkMenuViewModel

    // Factories injected by the parent coordinator
    private let makeConnectionsCoordinator: () -> ConnectionsCoordinator
    private let makeGroupsMenuCoordinator: () -> GroupsMenuCoordinator
    private let makeSubnetMenuCoordinator: () -> SubnetMenuCoordinator

    init(
        viewModel: NetworkMenuViewModel,
        makeConnectionsCoordinator: @escaping () -> ConnectionsCoordinator,
        makeGroupsMenuCoordinator: @escaping () -> GroupsMenuCoordinator,
        makeSubnetMenuCoordinator: @escaping () -> SubnetMenuCoordinator
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeConnectionsCoordinator = makeConnectionsCoordinator
        self.makeGroupsMenuCoordinator = makeGroupsMenuCoordinator
        self.makeSubnetMenuCoordinator = makeSubnetMenuCoordinator
    }

    var body: some View {
        NavigationStack {
            List {
                // Connections
                Button {
                    viewModel.showConnectionsView()
                } label: {
                    row(icon: "person.2.fill", title: "Connections", subtitle: "View your connections")
                }
                .buttonStyle(.plain)

                // Groups
                Button {
                    viewModel.showGroupsMenuView()
                } label: {
                    row(icon: "person.3.sequence", title: "Groups", subtitle: "View your groups")
                }
                .buttonStyle(.plain)

                // Subnets
                Button {
                    viewModel.showSubnetMenuView()
                } label: {
                    row(icon: "network.badge.shield.half.filled", title: "Subnets", subtitle: "View your subnets")
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Social Network")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $viewModel.showConnections) {
                makeConnectionsCoordinator().start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showGroupsMenu) {
                makeGroupsMenuCoordinator().start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showSubnetMenu) {
                makeSubnetMenuCoordinator().start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Row builder
    private func row(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
