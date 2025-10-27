//
//  ConnectionsViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import Foundation
import Combine

@MainActor
final class ConnectionsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: ConnectionsModel
    
    // MARK: - Published
    @Published var connections: [Connection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(model: ConnectionsModel = ConnectionsModel()) {
        self.model = model
    }
    
    // MARK: - Actions
    func loadConnections() async {
        isLoading = true
        errorMessage = nil
        
        do {
            connections = try await model.fetchConnections()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
