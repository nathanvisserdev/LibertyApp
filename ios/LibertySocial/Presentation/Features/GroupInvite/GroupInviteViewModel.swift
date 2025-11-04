//
//  GroupInviteViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import Combine

@MainActor
final class GroupInviteViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: GroupInviteModel
    private let groupId: String
    private let TokenProvider: TokenProviding
    private let inviteService: GroupInviteSession
    private let groupService: GroupSession
    
    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published (Output State)
    @Published var invitees: [InviteeUser] = []
    @Published var selectedUserIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var isSendingInvites: Bool = false
    @Published var errorMessage: String?
    @Published var isPrivate: Bool = false
    
    // MARK: - Published (UI State)
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // MARK: - Navigation Signals (Output for Coordinator)
    let didFinishSuccessfully = PassthroughSubject<Void, Never>()
    
    // MARK: - Filter State
    @Published var filterType: FilterType = .connections
    @Published var includeAdditional: Bool = false // For followers or strangers
    
    enum FilterType: String, CaseIterable {
        case connections = "Connections"
        case followers = "Followers"
        case strangers = "Strangers"
    }
    
    // Computed property to get available filter types based on privacy
    var availableFilters: [FilterType] {
        if isPrivate {
            return [.connections, .strangers]
        } else {
            return [.connections, .followers]
        }
    }
    
    // Display label for the additional filter option
    var additionalFilterLabel: String {
        isPrivate ? "Include Strangers" : "Include Followers"
    }
    
    // MARK: - Init
    init(
        model: GroupInviteModel = GroupInviteModel(),
        groupId: String,
        TokenProvider: TokenProviding = AuthService.shared,
        inviteService: GroupInviteSession = GroupInviteService.shared,
        groupService: GroupSession = GroupService.shared
    ) {
        self.model = model
        self.groupId = groupId
        self.TokenProvider = TokenProvider
        self.inviteService = inviteService
        self.groupService = groupService
        
        // Subscribe to invite service events
        subscribeToInviteEvents()
    }
    
    // MARK: - Service Subscription
    
    private func subscribeToInviteEvents() {
        inviteService.inviteEvents
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .invitesSentSuccessfully(let count):
                    self.isSendingInvites = false
                    self.alertMessage = count == 1 ? "Sent 1 invite" : "Sent \(count) invites"
                    self.showSuccessAlert = true
                    
                    // Invalidate group cache so the group member list refreshes
                    self.groupService.invalidateCache()
                    
                    // Signal coordinator to dismiss
                    self.didFinishSuccessfully.send()
                    
                case .invitesFailed(let error):
                    self.isSendingInvites = false
                    self.alertMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    var selectedCount: Int {
        selectedUserIds.count
    }
    
    var canSendInvites: Bool {
        !selectedUserIds.isEmpty && !isSendingInvites
    }
    
    // MARK: - Intents (User Actions)
    
    func loadUserPrivacyStatus() async {
        do {
            isPrivate = try await TokenProvider.getCurrentUserIsPrivate()
        } catch {
            print("Error fetching user privacy status: \(error)")
            // Default to false if we can't fetch
            isPrivate = false
        }
    }
    
    func fetchInvitees() async {
        isLoading = true
        errorMessage = nil
        
        do {
            var includeTypes: [String] = ["connections"]
            
            // Add additional filter if enabled
            if includeAdditional {
                if isPrivate {
                    includeTypes.append("strangers")
                } else {
                    includeTypes.append("followers")
                }
            }
            
            let include = includeTypes.joined(separator: ",")
            
            invitees = try await model.fetchInvitees(groupId: groupId, include: include, exclude: nil)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching invitees: \(error)")
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
    
    func selectAll() {
        selectedUserIds = Set(invitees.map { $0.id })
    }
    
    func deselectAll() {
        selectedUserIds.removeAll()
    }
    
    func toggleAdditionalFilter() {
        includeAdditional.toggle()
        // Keep existing selections - they'll be filtered after fetching new invitees
        Task {
            await fetchInvitees()
            // After fetching, remove any selections that are no longer in the invitees list
            let validUserIds = Set(invitees.map { $0.id })
            selectedUserIds = selectedUserIds.intersection(validUserIds)
        }
    }
    
    func changeFilter(_ newFilter: FilterType) {
        filterType = newFilter
        // Keep existing selections - they'll be filtered after fetching new invitees
        Task {
            await fetchInvitees()
            // After fetching, remove any selections that are no longer in the invitees list
            let validUserIds = Set(invitees.map { $0.id })
            selectedUserIds = selectedUserIds.intersection(validUserIds)
        }
    }
    
    func sendInvites() async {
        guard !selectedUserIds.isEmpty else { return }
        
        isSendingInvites = true
        
        do {
            let userIdsArray = Array(selectedUserIds)
            // Service will emit events that we're subscribed to
            try await inviteService.sendInvites(groupId: groupId, userIds: userIdsArray)
        } catch {
            // Service already emitted the error event, but ensure we reset state
            isSendingInvites = false
        }
    }
}
