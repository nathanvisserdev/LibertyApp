//
//  ConnectionRequestsView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
import Combine

struct ConnectionRequestsView: View {
    @StateObject private var viewModel = ConnectionRequestsViewModel()
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading requests...")
                        .padding()
                } else if viewModel.requests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No pending requests")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.requests) { request in
                        ConnectionRequestRowView(request: request)
                    }
                }
            }
            .navigationTitle("Connection Requests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadRequests()
            }
        }
    }
}

struct ConnectionRequestRowView: View {
    let request: IncomingConnectionRequest
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile photo
            if let photoURL = request.requester.photo, let url = URL(string: photoURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(request.requester.firstName) \(request.requester.lastName)")
                    .font(.headline)
                
                if let username = request.requester.username {
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(requestTypeText(request.type))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func requestTypeText(_ type: String) -> String {
        switch type {
        case "ACQUAINTANCE":
            return "Wants to connect as acquaintances"
        case "STRANGER":
            return "Wants to connect as strangers"
        case "FOLLOW":
            return "Wants to follow you"
        default:
            return "Connection request"
        }
    }
}

struct IncomingConnectionRequest: Identifiable {
    let id: String
    let type: String
    let requester: RequesterInfo
    
    struct RequesterInfo {
        let id: String
        let firstName: String
        let lastName: String
        let username: String?
        let photo: String?
    }
}

@MainActor
class ConnectionRequestsViewModel: ObservableObject {
    @Published var requests: [IncomingConnectionRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedRequests = try await AuthService.fetchIncomingConnectionRequests()
            
            requests = fetchedRequests.map { request in
                IncomingConnectionRequest(
                    id: request.id,
                    type: request.type,
                    requester: IncomingConnectionRequest.RequesterInfo(
                        id: request.requester?.id ?? "",
                        firstName: request.requester?.firstName ?? "",
                        lastName: request.requester?.lastName ?? "",
                        username: request.requester?.username,
                        photo: request.requester?.photo
                    )
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
