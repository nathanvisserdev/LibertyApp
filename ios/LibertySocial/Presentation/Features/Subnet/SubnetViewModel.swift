
import Foundation
import Combine

@MainActor
final class SubnetViewModel: ObservableObject {
    @Published var subnet: Subnet?
    @Published var members: [SubnetMember] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showAddMembersSheet: Bool = false
    
    private let model: SubnetModel
    private let subnetService: SubnetSession
    private var cancellables = Set<AnyCancellable>()
    
    init(model: SubnetModel = SubnetModel(), subnet: Subnet? = nil, subnetService: SubnetSession = SubnetService.shared) {
        self.model = model
        self.subnet = subnet
        self.subnetService = subnetService
        
        subnetService.subnetsDidChange
            .sink { [weak self] in
                Task { @MainActor [weak self] in
                    await self?.fetchMembers()
                }
            }
            .store(in: &cancellables)
    }
    
    func setSubnet(_ subnet: Subnet) {
        self.subnet = subnet
    }
    
    func fetchMembers() async {
        guard let subnet = subnet else { return }
        
        print("🔍 Fetching members for subnet: \(subnet.id)")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMembers = try await model.fetchMembers(subnetId: subnet.id)
            members = fetchedMembers
            print("✅ Fetched \(fetchedMembers.count) members")
            if !fetchedMembers.isEmpty {
                print("Members: \(fetchedMembers.map { "\($0.user.firstName ?? "") \($0.user.lastName ?? "")" })")
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error fetching subnet members: \(error)")
        }
        
        isLoading = false
    }
    
    func showAddMembers() {
        showAddMembersSheet = true
    }
    
    func deleteMember(_ member: SubnetMember) async -> (success: Bool, message: String) {
        guard let subnet = subnet else {
            return (false, "No subnet selected")
        }
        
        do {
            try await model.deleteMember(subnetId: subnet.id, userId: member.userId)
            
            members.removeAll { $0.id == member.id }
            
            subnetService.invalidateCache()
            
            let memberName = "\(member.user.firstName ?? "") \(member.user.lastName ?? "")".trimmingCharacters(in: .whitespaces)
            let displayName = memberName.isEmpty ? "@\(member.user.username)" : memberName
            return (true, "'\(displayName)' removed")
        } catch {
            return (false, error.localizedDescription)
        }
    }
}
