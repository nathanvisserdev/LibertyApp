//
//  ConnectionsListViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import Foundation
import Combine

@MainActor
final class ConnectionsListViewModel: ObservableObject {
    // MARK: - Dependencies
    private let model: ConnectionsListModel
    
    // MARK: - Callbacks
    private let onUserSelected: (String) -> Void
    
    // MARK: - Published
    @Published var connections: [Connection] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    init(model: ConnectionsListModel = ConnectionsListModel(),
         onUserSelected: @escaping (String) -> Void) {
        self.model = model
        self.onUserSelected = onUserSelected
    }
    
    // MARK: - Actions
    
    func selectUser(userId: String) {
        onUserSelected(userId)
    }
    
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
