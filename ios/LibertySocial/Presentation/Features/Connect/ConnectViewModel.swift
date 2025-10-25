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
    @Published var selectedType: String? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var requestSent = false
    
    func sendConnectionRequest(userId: String, type: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            try await ConnectModel.sendConnectionRequest(userId: userId, type: type)
            requestSent = true
            successMessage = "Connection request sent!"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
