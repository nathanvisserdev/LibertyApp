
import Foundation
import Combine
import SwiftUI

@MainActor
final class SubnetListViewModel: ObservableObject {
    
    private let model: SubnetListModel
    private let subnetService: SubnetSession
    private var cancellables = Set<AnyCancellable>()
    
    @Published var subnets: [Subnet] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var showCreateSubnet: Bool = false
    @Published var showSubnetView: Bool = false
    @Published var selectedSubnet: Subnet?
    @Published var showAddSubnetMembers: Bool = false
    @Published var selectedSubnetId: String?
    
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var alertMessage: String = ""
    
    var makeCreateSubnetView: (() -> AnyView)?
    var makeSubnetView: ((Subnet) -> AnyView)?
    var makeAddSubnetMembersView: ((String) -> AnyView)?
    var onNavigate: ((NextSubnetView, String?) -> Void)?
    
    init(model: SubnetListModel, subnetService: SubnetSession) {
        self.model = model
        self.subnetService = subnetService
        
        subnetService.subnetsDidChange
            .sink { [weak self] in
                self?.refreshSubnets()
            }
            .store(in: &cancellables)
    }
    
    func fetchSubnets() async {
        isLoading = true
        errorMessage = nil
        
        do {
            subnets = try await model.fetchSubnets()
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching subnets: \(error)")
        }
        
        isLoading = false
    }
    
    func showCreateSubnetView() {
        showCreateSubnet = true
    }
    
    func hideCreateSubnetView() {
        showCreateSubnet = false
    }
    
    func showSubnet(_ subnet: Subnet) {
        selectedSubnet = subnet
        showSubnetView = true
    }
    
    func hideSubnet() {
        selectedSubnet = nil
        showSubnetView = false
    }
    
    func refreshSubnets() {
        Task {
            await fetchSubnets()
        }
    }
    
    func deleteSubnet(_ subnet: Subnet) async {
        do {
            try await model.deleteSubnet(subnetId: subnet.id)
            
            subnets.removeAll { $0.id == subnet.id }
            
            alertMessage = "'\(subnet.name)' deleted successfully"
            showSuccessAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
            print("Error deleting subnet: \(error)")
        }
    }
    
    func moveSubnet(from source: IndexSet, to destination: Int) {
        subnets.move(fromOffsets: source, toOffset: destination)
        
        Task {
            await updateAllSubnetOrderings()
        }
    }
    
    private func updateAllSubnetOrderings() async {
        for (index, subnet) in subnets.enumerated() {
            do {
                try await model.updateSubnetOrdering(subnetId: subnet.id, ordering: index)
            } catch {
                print("Error updating ordering for subnet \(subnet.name): \(error)")
            }
        }
    }
    
    func navigateToAddSubnetMembersView(subnetId: String) {
        selectedSubnetId = subnetId
        showAddSubnetMembers = true
    }
}
