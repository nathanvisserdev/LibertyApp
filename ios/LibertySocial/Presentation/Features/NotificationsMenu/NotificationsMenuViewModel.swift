//
//  NotificationsMenuViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-24.
//

import Foundation
import Combine

@MainActor
final class NotificationsMenuViewModel: ObservableObject {
    private let model: NotificationsMenuModel
    
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(model: NotificationsMenuModel = NotificationsMenuModel()) {
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
        guard let notification = notifications.first(where: { $0.id == requestId }) else {
            return
        }
        
        do {
            if notification.type == .connectionRequest {
                try await model.acceptConnectionRequest(requestId: requestId)
            } else if notification.type == .groupJoinRequest {
                try await model.acceptGroupJoinRequest(requestId: requestId)
            }
            notifications.removeAll { $0.id == requestId }
        } catch {
            errorMessage = "Failed to accept request: \(error.localizedDescription)"
        }
    }
    
    func declineConnectionRequest(requestId: String) async {
        guard let notification = notifications.first(where: { $0.id == requestId }) else {
            return
        }
        
        do {
            if notification.type == .connectionRequest {
                try await model.declineConnectionRequest(requestId: requestId)
            } else if notification.type == .groupJoinRequest {
                try await model.declineGroupJoinRequest(requestId: requestId)
            }
            notifications.removeAll { $0.id == requestId }
        } catch {
            errorMessage = "Failed to decline request: \(error.localizedDescription)"
        }
    }
}
