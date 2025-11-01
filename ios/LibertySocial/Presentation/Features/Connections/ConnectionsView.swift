//
//  ConnectionsView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import SwiftUI

struct UserIdWrapper: Identifiable {
    let id: String
}

struct ConnectionsView: View {
    @StateObject private var viewModel: ConnectionsViewModel
    @State private var selectedUserId: String?
    
    init(viewModel: ConnectionsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.title)
                            .fontWeight(.bold)
                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else if viewModel.connections.isEmpty {
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
                } else {
                    List(viewModel.connections) { connection in
                        Button {
                            selectedUserId = connection.userId
                        } label: {
                            HStack(spacing: 12) {
                                // Profile Photo
                                if let photoKey = connection.profilePhoto, !photoKey.isEmpty {
                                    ProfilePhotoView(photoKey: photoKey)
                                        .frame(width: 25, height: 25)
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 25, height: 25)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        )
                                }
                                
                                // User Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(connection.firstName) \(connection.lastName)")
                                        .font(.headline)
                                    
                                    Text("@\(connection.username)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    // Connection Type Badge
                                    Text(connectionTypeLabel(connection.type))
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(connectionTypeColor(connection.type).opacity(0.2))
                                        .foregroundColor(connectionTypeColor(connection.type))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadConnections()
            }
            .sheet(item: Binding(
                get: { selectedUserId.map { UserIdWrapper(id: $0) } },
                set: { selectedUserId = $0?.id }
            )) { wrapper in
                let coordinator = ProfileCoordinator(userId: wrapper.id)
                coordinator.start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func connectionTypeLabel(_ type: String) -> String {
        switch type {
        case "ACQUAINTANCE":
            return "Acquaintance"
        case "STRANGER":
            return "Stranger"
        case "IS_FOLLOWING":
            return "Following"
        default:
            return type
        }
    }
    
    private func connectionTypeColor(_ type: String) -> Color {
        switch type {
        case "ACQUAINTANCE":
            return .blue
        case "STRANGER":
            return .orange
        case "IS_FOLLOWING":
            return .purple
        default:
            return .gray
        }
    }
}

#Preview {
    ConnectionsCoordinator().start()
}
