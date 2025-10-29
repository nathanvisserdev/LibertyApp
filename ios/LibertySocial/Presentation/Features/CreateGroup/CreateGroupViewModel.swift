//
//  CreateGroupViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation
import Combine

@MainActor
final class CreateGroupViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var selectedGroupType: GroupType = .autocratic
    @Published var selectedGroupPrivacy: GroupPrivacy = .publicGroup {
        didSet {
            // Force autocratic type when personal privacy is selected
            if selectedGroupPrivacy == .personalGroup && selectedGroupType == .roundTable {
                selectedGroupType = .autocratic
            }
            // Force requires approval when private privacy is selected
            if selectedGroupPrivacy == .privateGroup {
                requiresApproval = true
            }
        }
    }
    @Published var isHidden: Bool = false
    @Published var requiresApproval: Bool = true
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    
    // Round Table specific fields
    @Published var selectedAdmins: [RoundTableAdmin] = []
    @Published var viceChairId: String?
    @Published var enableElections: Bool = false
    @Published var selectedElectionCycle: ElectionCycle = .oneYear
    
    let maxNameCharacters = 100
    let maxDescriptionCharacters = 250
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    var remainingNameCharacters: Int {
        maxNameCharacters - name.count
    }
    
    var remainingDescriptionCharacters: Int {
        maxDescriptionCharacters - description.count
    }
    
    var isValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty 
            && remainingNameCharacters >= 0 
            && remainingDescriptionCharacters >= 0
    }
    
    var canCreateRoundTable: Bool {
        selectedAdmins.count >= 1 && 
        selectedAdmins.count <= 4 && 
        viceChairId != nil
    }
    
    func addAdmin(_ admin: RoundTableAdmin) {
        guard selectedAdmins.count < 4 else { return }
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
    
    func submit() async -> Bool {
        guard !isSubmitting else { return false }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            if selectedGroupType == .roundTable {
                // Submit Round Table group
                guard canCreateRoundTable else {
                    errorMessage = "Please select at least 1 admin and a vice president"
                    isSubmitting = false
                    return false
                }
                
                guard let viceChairId = viceChairId else {
                    errorMessage = "Please select a vice president"
                    isSubmitting = false
                    return false
                }
                
                // Prepare admin data
                let admins = selectedAdmins.map { admin in
                    [
                        "userId": admin.userId,
                        "isModerator": admin.isModerator
                    ] as [String: Any]
                }
                
                let request = CreateRoundTableGroupRequest(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                    groupPrivacy: selectedGroupPrivacy.rawValue,
                    requiresApproval: requiresApproval,
                    viceChairId: viceChairId,
                    admins: admins,
                    electionCycle: enableElections ? selectedElectionCycle.rawValue : nil
                )
                
                _ = try await CreateGroupModel.createRoundTableGroup(request: request)
            } else {
                // Submit regular autocratic group
                guard isValid else {
                    isSubmitting = false
                    return false
                }
                
                _ = try await CreateGroupModel.createGroup(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                    groupType: selectedGroupType.rawValue,
                    groupPrivacy: selectedGroupPrivacy.rawValue,
                    isHidden: isHidden
                )
            }
            
            isSubmitting = false
            return true
        } catch let error as NSError {
            if error.code == 402 {
                errorMessage = "Premium membership required to create hidden groups"
            } else {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
            return false
        } catch {
            errorMessage = error.localizedDescription
            isSubmitting = false
            return false
        }
    }
}
