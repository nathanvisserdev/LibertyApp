//
//  NotificationViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation
import Combine

@MainActor
class NotificationViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: NotificationModel
    
    // MARK: - Published
    @Published var connectionRequests: [ConnectionRequestRow] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(model: NotificationModel = NotificationModel()) {
        self.model = model
    }
    
    func fetchIncomingConnectionRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            connectionRequests = try await model.fetchIncomingConnectionRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
