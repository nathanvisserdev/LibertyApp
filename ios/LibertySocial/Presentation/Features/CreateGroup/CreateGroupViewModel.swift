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
    
    func submit() async -> Bool {
        guard !isSubmitting else { return false }
        guard isValid else { return false }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            try await authService.createGroup(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                groupType: selectedGroupType.rawValue,
                groupPrivacy: selectedGroupPrivacy.rawValue,
                isHidden: isHidden
            )
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
