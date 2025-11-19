
import Foundation
import SwiftUI
import Combine

@MainActor
final class GroupsListViewModel: ObservableObject {
    
    private let model: GroupsListModel
    private let AuthManagerBadName: AuthManaging
    private let groupService: GroupSession
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var showCreateGroup: Bool = false
    @Published var showGroupView: Bool = false
    @Published var selectedGroup: UserGroup?
    @Published var showSuggestedGroups: Bool = false
    @Published var showGroupInvite: Bool = false
    @Published var groupInviteGroupId: String?
    
    var makeCreateGroupView: (() -> AnyView)?
    var makeGroupView: ((UserGroup) -> AnyView)?
    var makeSuggestedGroupsView: (() -> AnyView)?
    
    init(model: GroupsListModel,
         AuthManagerBadName: AuthManaging,
         groupService: GroupSession
    ) {
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
        showCreateGroup = true
    }
    
    func hideCreateGroupView() {
        showCreateGroup = false
    }
    
    func showSuggestedGroupsView() {
        showSuggestedGroups = true
    }
    
    func hideSuggestedGroupsView() {
        showSuggestedGroups = false
    }
    
    func showGroup(_ group: UserGroup) {
        selectedGroup = group
        showGroupView = true
    }
    
    func hideGroup() {
        selectedGroup = nil
        showGroupView = false
    }
}
