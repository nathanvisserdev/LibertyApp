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
    @Published var selectedGroupType: GroupType = .publicGroup
    @Published var isHidden: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    
    let maxNameCharacters = 100
    let maxDescriptionCharacters = 500
    
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
