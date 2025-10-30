//
//  AddSubnetMembersViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation
import Combine

@MainActor
final class AddSubnetMembersViewModel: ObservableObject {
    @Published var subnetId: String?
    @Published var eligibleConnections: [Connection] = []
    @Published var selectedUserIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let model: AddSubnetMembersModel
    
    init(model: AddSubnetMembersModel = AddSubnetMembersModel()) {
        self.model = model
    }
    
    func setSubnetId(_ id: String) {
        self.subnetId = id
    }
    
    func fetchEligibleConnections() async {
        guard let subnetId = subnetId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let connections = try await model.fetchEligibleConnections(subnetId: subnetId)
            eligibleConnections = connections
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching eligible connections: \(error)")
        }
        
        isLoading = false
    }
    
    func toggleSelection(userId: String) {
        if selectedUserIds.contains(userId) {
            selectedUserIds.remove(userId)
        } else {
            selectedUserIds.insert(userId)
        }
    }
    
    func isSelected(userId: String) -> Bool {
        selectedUserIds.contains(userId)
    }
}
