
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
    @Published var shouldPresentGroupView: Bool = false
    @Published var shouldPresentSuggestedGroupsView: Bool = false
    @Published var shouldPresentGroupInviteView: Bool = false
    @Published var shouldPresentAboutGroupView: Bool = false
    @Published var groupId: String?
    
    var presentCreateGroupView: (() -> AnyView)?
    var presentSuggestedGroupsView: (() -> AnyView)?
    var presentGroupInviteView: ((String) -> AnyView)?
    var presentGroupView: ((String) -> AnyView)?
    var presentAboutGroupView: ((String) -> AnyView)?
    var onSuggestedGroupsViewFinish: (() -> Void)?
    var handleCreateGroupDismissed: (() -> Void)?
    var handleGroupsListViewDismiss: (() -> Void)?
    
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
    
    func onGroupTap(groupId: String) {
        self.groupId = groupId
        shouldPresentGroupView = true
    }
    
    func hideGroupRoomView() {
        self.groupId = nil
        shouldPresentGroupView = false
    }
    
    func showGroupInviteView(groupId: String) {
        self.groupId = groupId
        shouldPresentGroupInviteView = true
    }
    
    func showAboutGroupView(groupId: String) {
        self.groupId = groupId
        shouldPresentAboutGroupView = true
    }
    
    func onSuggestedGroupsViewDismissed() {
        onSuggestedGroupsViewFinish?()
    }
    
    func onCreateGroupDismissed() {
        handleCreateGroupDismissed?()
    }
    
    func onGroupsListViewDismiss() {
        handleGroupsListViewDismiss?()
    }
}
