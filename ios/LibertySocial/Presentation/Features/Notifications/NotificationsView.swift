//
//  NotificationsView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-24.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView("Loading notifications...")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.loadNotifications() }
                        }
                    }
                    .padding()
                } else if viewModel.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        Text("No notifications")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.notifications) { notification in
                            NotificationRow(
                                notification: notification,
                                onAccept: { requestId in
                                    Task {
                                        await viewModel.acceptConnectionRequest(requestId: requestId)
                                    }
                                },
                                onDecline: { requestId in
                                    Task {
                                        await viewModel.declineConnectionRequest(requestId: requestId)
                                    }
                                }
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("Notifications")
        }
        .task {
            await viewModel.loadNotifications()
        }
    }
}

struct NotificationRow: View {
    let notification: NotificationItem
    let onAccept: (String) -> Void
    let onDecline: (String) -> Void
    
    @State private var isProcessing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with type badge
            HStack {
                Text(notification.type == .connectionRequest ? "Connection Request" : 
                     notification.type == .groupInvite ? "Group Invite" : 
                     "Group Join Request")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor(for: notification.type))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                
                Spacer()
                
                Text(timeAgo(from: notification.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // User info and request details
            if let user = notification.user {
                HStack(spacing: 12) {
                    // Profile photo placeholder
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("\(user.firstName.prefix(1))\(user.lastName.prefix(1))")
                                .font(.caption)
                                .fontWeight(.bold)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("@\(user.username)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let requestType = notification.requestType {
                            Text(requestTypeText(requestType))
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Action buttons
            if notification.type == .connectionRequest {
                HStack(spacing: 12) {
                    // Accept Button
                    Button {
                        guard !isProcessing else { return }
                        isProcessing = true
                        onAccept(notification.id)
                    } label: {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        } else {
                            Text("Accept")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                    .buttonStyle(.plain)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .disabled(isProcessing)
                    
                    // Decline Button
                    Button {
                        guard !isProcessing else { return }
                        isProcessing = true
                        onDecline(notification.id)
                    } label: {
                        Text("Decline")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                    .disabled(isProcessing)
                }
            }
        }
        .padding(.vertical, 8)
        .opacity(isProcessing ? 0.6 : 1.0)
    }
    
    private func badgeColor(for type: NotificationItem.NotificationType) -> Color {
        switch type {
        case .connectionRequest:
            return .blue
        case .groupInvite:
            return .green
        case .groupJoinRequest:
            return .orange
        }
    }
    
    private func requestTypeText(_ type: String) -> String {
        switch type {
        case "ACQUAINTANCE":
            return "Wants to connect as acquaintances"
        case "STRANGER":
            return "Wants to connect as strangers"
        case "IS_FOLLOWING":
            return "Wants to follow you"
        default:
            return type
        }
    }
    
    private func timeAgo(from isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return "" }
        
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    NotificationsView()
}
