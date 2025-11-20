
import Foundation
import Combine
import SwiftUI

@MainActor
final class CreateSubnetViewModel: ObservableObject {
    
    private let model: CreateSubnetModel
    private let subnetService: SubnetSession
    
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var selectedVisibility: SubNetVisibilityOption = .privateVisibility
    @Published var isDefault: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String = ""
    @Published var shouldDismiss: Bool = false
    @Published var showAddMembers: Bool = false
    @Published var createdSubnetId: String?
    
    var makeAddSubnetMembersView: ((String) -> AnyView)?
    
    init(model: CreateSubnetModel, subnetService: SubnetSession) {
        self.model = model
        self.subnetService = subnetService
    }
    
    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    
    func submit() async -> Bool {
        guard canSubmit else { return false }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
            let descriptionValue = trimmedDescription.isEmpty ? nil : trimmedDescription
            
            let response = try await model.createSubnet(
                name: trimmedName,
                description: descriptionValue,
                visibility: selectedVisibility.rawValue
            )
            
            if isDefault {
                try await model.setDefaultSubnet(subnetId: response.id)
            }
            
            createdSubnetId = response.id
            
            subnetService.invalidateCache()
            
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
}
