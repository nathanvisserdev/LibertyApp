
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
    @Published var shouldPresentCreateGroupView: Bool = false
    @Published var showGroupView: Bool = false
    @Published var shouldPresentGroupView: UserGroup?
    @Published var shouldPresentSuggestedGroupsView: Bool = false
    @Published var shouldPresentGroupInviteView: Bool = false
    @Published var shouldPresentAboutGroupView: Bool = false
    @Published var groupInviteGroupId: String?
    @Published var aboutGroupId: String?
    
    var presentCreateGroupView: (() -> AnyView)?
    var presentGroupView: ((UserGroup) -> AnyView)?
    var presentSuggestedGroupsView: (() -> AnyView)?
    var presentGroupInviteView: ((String) -> AnyView)?
    var presentAboutGroupView: ((String) -> AnyView)?
    
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
        shouldPresentCreateGroupView = true
    }
    
    func hideCreateGroupView() {
        shouldPresentCreateGroupView = false
    }
    
    func showSuggestedGroupsView() {
        shouldPresentSuggestedGroupsView = true
    }
    
    func hideSuggestedGroupsView() {
        shouldPresentSuggestedGroupsView = false
    }
    
    func showGroup(_ group: UserGroup) {
        shouldPresentGroupView = group
        showGroupView = true
    }
    
    func hideGroup() {
        shouldPresentGroupView = nil
        showGroupView = false
    }
    
    func signalToPresentGroupInviteView(groupId: String) {
        groupInviteGroupId = groupId
        shouldPresentGroupInviteView = true
    }
    
    func publishGroupTapped(groupId: String) {
        aboutGroupId = groupId
        shouldPresentAboutGroupView = true
    }
}
