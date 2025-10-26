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
        do {
            try await model.acceptConnectionRequest(requestId: requestId)
            // Remove the accepted request from the list
            notifications.removeAll { $0.id == requestId }
        } catch {
            errorMessage = "Failed to accept request: \(error.localizedDescription)"
        }
    }
}
