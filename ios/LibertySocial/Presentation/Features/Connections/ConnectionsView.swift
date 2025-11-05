//
//  ConnectionsView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import SwiftUI

struct UserIdWrapper: Identifiable { let id: String }

struct ConnectionsView: View {
    @StateObject private var viewModel: ConnectionsViewModel
    @State private var selectedUserId: String?
    private let makeProfileCoordinator: (String) -> ProfileCoordinator

    init(viewModel: ConnectionsViewModel,
         makeProfileCoordinator: @escaping (String) -> ProfileCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeProfileCoordinator = makeProfileCoordinator
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    ErrorState(message: error) { Task { await viewModel.loadConnections() } }
                } else if viewModel.connections.isEmpty {
                    EmptyState()
                } else {
                    List(viewModel.connections) { c in
                        Button {
                            selectedUserId = c.userId
                        } label: {
                            ConnectionRow(
                                firstName: c.firstName,
                                lastName:  c.lastName,
                                username:  c.username,
                                profilePhoto: c.profilePhoto,
                                type: c.type
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadConnections() }
            .sheet(item: Binding(
                get: { selectedUserId.map { UserIdWrapper(id: $0) } },
                set: { selectedUserId = $0?.id }
            )) { wrapper in
                makeProfileCoordinator(wrapper.id).start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Subviews

private struct ConnectionRow: View {
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String?
    let type: String

    var body: some View {
        HStack(spacing: 12) {
            ProfileThumb(photoKey: profilePhoto)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(firstName) \(lastName)")
                    .font(.headline)
                Text("@\(username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Badge(text: label(for: type), color: color(for: type))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func label(for type: String) -> String {
        switch type {
        case "ACQUAINTANCE": return "Acquaintance"
        case "STRANGER":     return "Stranger"
        case "IS_FOLLOWING": return "Following"
        default:             return type
        }
    }

    private func color(for type: String) -> Color {
        switch type {
        case "ACQUAINTANCE": return .blue
        case "STRANGER":     return .orange
        case "IS_FOLLOWING": return .purple
        default:             return .gray
        }
    }
}

private struct ProfileThumb: View {
    let photoKey: String?
    var body: some View {
        Group {
            if let key = photoKey, !key.isEmpty {
                ProfilePhotoView(photoKey: key)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    )
            }
        }
        .frame(width: 25, height: 25)
    }
}

private struct Badge: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

private struct EmptyState: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No Connections")
                .font(.title2)
                .fontWeight(.semibold)
            Text("You haven't connected with anyone yet")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

private struct ErrorState: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error").font(.title).fontWeight(.bold)
            Text(message)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again", action: retry)
                .buttonStyle(.bordered)
        }
    }
}
