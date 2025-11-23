
import Foundation
import Combine

@MainActor
final class GroupInviteViewModel: ObservableObject {
    private let model: GroupInviteModel
    private let groupId: String
    private let TokenProvider: TokenProviding
    private let inviteService: GroupInviteSession
    private let groupService: GroupSession
    private var cancellables = Set<AnyCancellable>()
    let didFinishSuccessfully = PassthroughSubject<Void, Never>()
    var handleDisappear: (() -> Void)?
    var onSuccess: (() -> Void)?
    
    @Published var invitees: [InviteeUser] = []
    @Published var selectedUserIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var isSendingInvites: Bool = false
    @Published var errorMessage: String?
    @Published var isPrivate: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var filterType: FilterType = .connections
    @Published var includeAdditional: Bool = false // For followers or strangers
    
    enum FilterType: String, CaseIterable {
        case connections = "Connections"
        case followers = "Followers"
        case strangers = "Strangers"
    }
    
    var availableFilters: [FilterType] {
        if isPrivate {
            return [.connections, .strangers]
        } else {
            return [.connections, .followers]
        }
    }
    
    var additionalFilterLabel: String {
        isPrivate ? "Include Strangers" : "Include Followers"
    }
    
    init(
        model: GroupInviteModel,
        groupId: String,
        TokenProvider: TokenProviding,
        inviteService: GroupInviteSession,
        groupService: GroupSession
    ) {
        self.model = model
        self.groupId = groupId
        self.TokenProvider = TokenProvider
        self.inviteService = inviteService
        self.groupService = groupService
        
        subscribeToInviteEvents()
    }
    
    private func subscribeToInviteEvents() {
        inviteService.inviteEvents
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .invitesSentSuccessfully(let count):
                    self.isSendingInvites = false
                    self.alertMessage = count == 1 ? "Sent 1 invite" : "Sent \(count) invites"
                    self.showSuccessAlert = true
                    self.didFinishSuccessfully.send()
                case .invitesFailed(let error):
                    self.isSendingInvites = false
                    self.alertMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    var selectedCount: Int {
        selectedUserIds.count
    }
    
    var canSendInvites: Bool {
        !selectedUserIds.isEmpty && !isSendingInvites
    }
    
    func loadUserPrivacyStatus() async {
        do {
            isPrivate = try await TokenProvider.getCurrentUserIsPrivate()
        } catch {
            print("Error fetching user privacy status: \(error)")
            isPrivate = false
        }
    }
    
    func fetchInvitees() async {
        isLoading = true
        errorMessage = nil
        do {
            var includeTypes: [String] = ["connections"]
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
        Task {
            await fetchInvitees()
            let validUserIds = Set(invitees.map { $0.id })
            selectedUserIds = selectedUserIds.intersection(validUserIds)
        }
    }
    
    func changeFilter(_ newFilter: FilterType) {
        filterType = newFilter
        Task {
            await fetchInvitees()
            let validUserIds = Set(invitees.map { $0.id })
            selectedUserIds = selectedUserIds.intersection(validUserIds)
        }
    }
    
    func sendInvites() async {
        guard !selectedUserIds.isEmpty else { return }
        isSendingInvites = true
        do {
            let userIdsArray = Array(selectedUserIds)
            try await inviteService.sendInvites(groupId: groupId, userIds: userIdsArray)
        } catch {
            isSendingInvites = false
        }
    }
}
