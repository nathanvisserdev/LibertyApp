//
//  SelectRoundTableAdminsViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-28.
//

import Foundation
import Combine

@MainActor
final class SelectRoundTableAdminsViewModel: ObservableObject {
    @Published var connections: [Connection] = []
    @Published var selectedAdmins: [RoundTableAdmin] = []
    @Published var viceChairId: String?
    @Published var enableElections: Bool = false
    @Published var selectedElectionCycle: ElectionCycle = .oneYear
    @Published var isLoading: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    var availableConnections: [Connection] {
        connections.filter { connection in
            !selectedAdmins.contains(where: { $0.userId == connection.userId })
        }
    }
    
    var canCreateGroup: Bool {
        selectedAdmins.count >= 1 && 
        selectedAdmins.count <= 4 && 
        viceChairId != nil &&
        !isSubmitting
    }
    
    func loadConnections() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let model = ConnectionsModel(authService: authService)
            connections = try await model.fetchConnections()
            isLoading = false
        } catch {
            errorMessage = "Failed to load connections: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func addAdmin(_ connection: Connection) {
        guard selectedAdmins.count < 4 else { return }
        let admin = RoundTableAdmin(from: connection)
        selectedAdmins.append(admin)
        
        // Auto-assign vice chair if only one admin, reset to nil when adding second admin
        if selectedAdmins.count == 1 {
            viceChairId = admin.userId
        } else if selectedAdmins.count == 2 {
            viceChairId = nil
        }
    }
    
    func removeAdmin(_ admin: RoundTableAdmin) {
        selectedAdmins.removeAll { $0.id == admin.id }
        
        // Reset or reassign vice chair
        if viceChairId == admin.userId {
            if selectedAdmins.count == 1 {
                viceChairId = selectedAdmins.first?.userId
            } else {
                viceChairId = nil
            }
        }
        
        // Auto-assign vice chair if only one admin remains
        if selectedAdmins.count == 1 {
            viceChairId = selectedAdmins.first?.userId
        }
    }
    
    func toggleModerator(adminId: String, isModerator: Bool) {
        if let index = selectedAdmins.firstIndex(where: { $0.userId == adminId }) {
            selectedAdmins[index].isModerator = isModerator
        }
    }
    
    func createGroup(name: String, groupPrivacy: GroupPrivacy) async -> Bool {
        guard canCreateGroup else { return false }
        guard let viceChairId = viceChairId else { return false }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            // Prepare admin data
            let admins = selectedAdmins.map { admin in
                [
                    "userId": admin.userId,
                    "isModerator": admin.isModerator
                ] as [String: Any]
            }
            
            try await authService.createRoundTableGroup(
                name: name,
                groupPrivacy: groupPrivacy.rawValue,
                viceChairId: viceChairId,
                admins: admins,
                electionCycle: enableElections ? selectedElectionCycle.rawValue : nil
            )
            
            isSubmitting = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSubmitting = false
            return false
        }
    }
}
