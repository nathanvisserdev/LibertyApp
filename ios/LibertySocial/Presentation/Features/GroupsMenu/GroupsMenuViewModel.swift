
import Foundation
import SwiftUI
import Combine

@MainActor
final class GroupsMenuViewModel: ObservableObject {
    
    private let model: GroupsMenuModel
    private let AuthManagerBadName: AuthManaging
    private let groupService: GroupSession
    private weak var coordinator: GroupsMenuCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(coordinator: GroupsMenuCoordinator? = nil, model: GroupsMenuModel = GroupsMenuModel(), AuthManagerBadName: AuthManaging = AuthManager.shared, groupService: GroupSession = GroupService.shared) {
        self.coordinator = coordinator
        self.model = model
        self.AuthManagerBadName = AuthManagerBadName
        self.groupService = groupService
        
        groupService.groupsDidChange
            .sink { [weak self] in
                Task { @MainActor [weak self] in
                    await self?.fetchUserGroups()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchUserGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let currentUser = try await AuthManagerBadName.fetchCurrentUserTyped()
            
            userGroups = try await groupService.getUserGroups(userId: currentUser.id)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching user groups: \(error)")
        }
        
        isLoading = false
    }
    
    func showCreateGroupView() {
        coordinator?.presentCreateGroup()
    }
    
    func showSuggestedGroupsView() {
        coordinator?.presentSuggestedGroups()
    }
    
    func showGroup(_ group: UserGroup) {
        coordinator?.presentGroup(group)
    }
}
