//
//  NotificationsViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-24.
//

import Foundation
import Combine

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let model: NotificationsModel
    
    init(model: NotificationsModel = NotificationsModel()) {
        self.model = model
    }
    
    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        
        do {
            notifications = try await model.fetchNotifications()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadNotifications()
    }
    
    func acceptConnectionRequest(requestId: String) async {
        // Find the notification to determine its type
        guard let notification = notifications.first(where: { $0.id == requestId }) else {
            return
        }
        
        do {
            if notification.type == .connectionRequest {
                try await model.acceptConnectionRequest(requestId: requestId)
            } else if notification.type == .groupJoinRequest {
                try await model.acceptGroupJoinRequest(requestId: requestId)
            }
            // Remove the accepted request from the list
            notifications.removeAll { $0.id == requestId }
        } catch {
            errorMessage = "Failed to accept request: \(error.localizedDescription)"
        }
    }
    
    func declineConnectionRequest(requestId: String) async {
        // Find the notification to determine its type
        guard let notification = notifications.first(where: { $0.id == requestId }) else {
            return
        }
        
        do {
            if notification.type == .connectionRequest {
                try await model.declineConnectionRequest(requestId: requestId)
            } else if notification.type == .groupJoinRequest {
                try await model.declineGroupJoinRequest(requestId: requestId)
            }
            // Remove the declined request from the list
            notifications.removeAll { $0.id == requestId }
        } catch {
            errorMessage = "Failed to decline request: \(error.localizedDescription)"
        }
    }
}
