
import Foundation
import SwiftUI
import Combine

@MainActor
final class CreateGroupViewModel: ObservableObject {
    
    private let model: CreateGroupModel
    private let groupService: GroupSession
    private let inviteService: GroupInviteSession
    private weak var coordinator: CreateGroupCoordinator?
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var selectedGroupType: GroupType = .autocratic
    @Published var selectedGroupPrivacy: GroupPrivacy = .publicGroup {
        didSet {
            if selectedGroupPrivacy == .personalGroup && selectedGroupType == .roundTable {
                selectedGroupType = .autocratic
            }
            if selectedGroupPrivacy == .privateGroup {
                requiresApproval = true
            }
        }
    }
    @Published var isHidden: Bool = false
    @Published var requiresApproval: Bool = true
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    
    @Published var createdGroupId: String?
    @Published var showAdminSelection: Bool = false
    
    var onFinished: (() -> Void)?
    var onCancelled: (() -> Void)?
    var onRequestAdminSelection: (() -> Void)?
    var createGroupSucceeded: ((String) -> Void)?
    
    @Published var selectedAdmins: [RoundTableAdmin] = []
    @Published var viceChairId: String?
    @Published var enableElections: Bool = false
    @Published var selectedElectionCycle: ElectionCycle = .oneYear
    
    @Published var connections: [Connection] = []
    @Published var isLoadingConnections: Bool = false
    
    let maxNameCharacters = 100
    let maxDescriptionCharacters = 250
    
    init(
        model: CreateGroupModel,
        groupService: GroupSession,
        inviteService: GroupInviteSession,
        coordinator: CreateGroupCoordinator
    ) {
        self.model = model
        self.groupService = groupService
        self.inviteService = inviteService
        self.coordinator = coordinator
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
    
    
    func fetchConnections() async {
        isLoadingConnections = true
        errorMessage = nil
        
        do {
            connections = try await model.fetchConnections()
            isLoadingConnections = false
        } catch {
            errorMessage = "Failed to load connections: \(error.localizedDescription)"
            isLoadingConnections = false
        }
    }
    
    func addAdmin(_ admin: RoundTableAdmin) {
        guard selectedAdmins.count < 4 else { return }
        selectedAdmins.append(admin)
        
        if selectedAdmins.count == 1 {
            viceChairId = admin.userId
        } else if selectedAdmins.count == 2 {
            viceChairId = nil
        }
    }
    
    func removeAdmin(_ admin: RoundTableAdmin) {
        selectedAdmins.removeAll { $0.id == admin.id }
        
        if viceChairId == admin.userId {
            if selectedAdmins.count == 1 {
                viceChairId = selectedAdmins.first?.userId
            } else {
                viceChairId = nil
            }
        }
        
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
                
                let response = try await model.createRoundTableGroup(request: request)
                
                createdGroupId = response.groupId
            } else {
                guard isValid else {
                    isSubmitting = false
                    return false
                }
                
                let response = try await model.createGroup(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
                    groupType: selectedGroupType.rawValue,
                    groupPrivacy: selectedGroupPrivacy.rawValue,
                    isHidden: isHidden
                )
                
                createdGroupId = response.groupId
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
    
    
    func cancel() {
        onCancelled?()
    }
    
    func onCreateGroupSuccess(for groupId: String) {
        groupService.invalidateCache()
        onFinished?()
        createGroupSucceeded?(groupId)
    }
}
