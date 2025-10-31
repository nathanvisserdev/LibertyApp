//
//  CreateSubnetViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import Combine

@MainActor
final class CreateSubnetViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: CreateSubnetModel
    private let onSubnetCreated: () -> Void
    
    // MARK: - Published (Input State)
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var selectedVisibility: SubNetVisibilityOption = .privateVisibility
    @Published var isDefault: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published (UI State for Navigation)
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String = ""
    @Published var shouldDismiss: Bool = false
    @Published var showAddMembers: Bool = false
    @Published var createdSubnetId: String?
    
    // MARK: - Init
    init(model: CreateSubnetModel = CreateSubnetModel(), onSubnetCreated: @escaping () -> Void = {}) {
        self.model = model
        self.onSubnetCreated = onSubnetCreated
    }
    
    // MARK: - Computed
    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    
    // MARK: - Intents (User Actions)
    func submit() async -> Bool {
        guard canSubmit else { return false }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
            let descriptionValue = trimmedDescription.isEmpty ? nil : trimmedDescription
            
            // Create the subnet
            let response = try await model.createSubnet(
                name: trimmedName,
                description: descriptionValue,
                visibility: selectedVisibility.rawValue
            )
            
            // If user wants this as default, set it
            if isDefault {
                try await model.setDefaultSubnet(subnetId: response.id)
            }
            
            // Store subnet ID for navigation
            createdSubnetId = response.id
            
            // Success - navigate to add members instead of dismissing
            successMessage = "'\(response.name)' created successfully!"
            showSuccessAlert = true
            isSubmitting = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            isSubmitting = false
            return false
        }
    }
    
    func dismissSuccessAlert() {
        showSuccessAlert = false
        showAddMembers = true
    }
    
    func onMembersAdded() {
        // Notify parent that subnet was created and members were added
        onSubnetCreated()
        // After members are added, dismiss the entire creation flow
        shouldDismiss = true
    }
}
