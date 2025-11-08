
import Foundation
import Combine

@MainActor
final class SubnetListViewModel: ObservableObject {
    @Published var subnets: [Subnet] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedSubnet: Subnet?
    
    private let model: SubnetListModel
    
    init(model: SubnetListModel = SubnetListModel()) {
        self.model = model
    }
    
    func fetchSubnets() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let networks = try await model.fetchSubnets()
            subnets = networks
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching subnets: \(error)")
        }
        
        isLoading = false
    }
    
    func selectSubnet(_ subnet: Subnet) {
        selectedSubnet = subnet
    }
    
    func passSubnetToViewModel(_ subnetViewModel: SubnetViewModel) {
        guard let subnet = selectedSubnet else { return }
        subnetViewModel.setSubnet(subnet)
    }
}
