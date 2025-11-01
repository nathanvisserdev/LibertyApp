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
    private let authSession: AuthSession
    
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
    @Published var shouldDismiss: Bool = false
    
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
    init(model: GroupInviteModel = GroupInviteModel(), groupId: String, authSession: AuthSession = AuthService.shared) {
        self.model = model
        self.groupId = groupId
        self.authSession = authSession
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
            isPrivate = try await authSession.getCurrentUserIsPrivate()
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
        selectedUserIds.removeAll()
        Task {
            await fetchInvitees()
        }
    }
    
    func changeFilter(_ newFilter: FilterType) {
        filterType = newFilter
        selectedUserIds.removeAll()
        Task {
            await fetchInvitees()
        }
    }
    
    func sendInvites() async {
        guard !selectedUserIds.isEmpty else { return }
        
        isSendingInvites = true
        
        do {
            let userIdsArray = Array(selectedUserIds)
            try await model.sendInvites(groupId: groupId, userIds: userIdsArray)
            
            let count = selectedUserIds.count
            alertMessage = count == 1 ? "Sent 1 invite" : "Sent \(count) invites"
            showSuccessAlert = true
            shouldDismiss = true
            isSendingInvites = false
        } catch {
            alertMessage = error.localizedDescription
            showErrorAlert = true
            isSendingInvites = false
            print("Error sending invites: \(error)")
        }
    }
}
