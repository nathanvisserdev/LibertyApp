//
//  ConnectViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import Foundation
import Combine

@MainActor
class ConnectViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: ConnectModel
    private let userId: String
    
    // MARK: - Published
    @Published var selectedType: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var requestSent = false
    
    // MARK: - Init
    init(model: ConnectModel = ConnectModel(), userId: String) {
        self.model = model
        self.userId = userId
    }
    
    func sendConnectionRequest(userId: String, type: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            _ = try await model.sendConnectionRequest(userId: userId, type: type)
            requestSent = true
            successMessage = "Connection request sent!"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
