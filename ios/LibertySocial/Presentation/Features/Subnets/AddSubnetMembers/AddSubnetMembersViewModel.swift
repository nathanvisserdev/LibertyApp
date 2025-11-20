
import Foundation
import Combine

@MainActor
final class AddSubnetMembersViewModel: ObservableObject {
    @Published var subnetId: String?
    @Published var eligibleConnections: [Connection] = []
    @Published var selectedUserIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAddingMembers: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var shouldDismiss: Bool = false
    
    private let model: AddSubnetMembersModel
    private let subnetService: SubnetSession
    
    init(model: AddSubnetMembersModel = AddSubnetMembersModel(), subnetService: SubnetSession = SubnetService.shared) {
        self.model = model
        self.subnetService = subnetService
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
    
    func addSelectedMembers() async -> Bool {
        guard let subnetId = subnetId else { return false }
        guard !selectedUserIds.isEmpty else { return false }
        
        isAddingMembers = true
        
        do {
            let userIdsArray = Array(selectedUserIds)
            try await model.addMembers(subnetId: subnetId, userIds: userIdsArray)
            
            subnetService.invalidateCache()
            
            let count = selectedUserIds.count
            alertMessage = count == 1 ? "Successfully added 1 member" : "Successfully added \(count) members"
            showSuccessAlert = true
            shouldDismiss = true
            isAddingMembers = false
            return true
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
            isAddingMembers = false
            print("Error adding members: \(error)")
            return false
        }
    }
}
