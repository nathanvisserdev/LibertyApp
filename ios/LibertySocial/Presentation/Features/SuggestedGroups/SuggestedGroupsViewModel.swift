
import Foundation
import Combine

@MainActor
final class SuggestedGroupsViewModel: ObservableObject {
    
    private let model: SuggestedGroupsModel
    
    @Published var joinableGroups: [UserGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var onDismiss: (() -> Void)?
    var onGroupSelected: ((UserGroup) -> Void)?
    
    init(model: SuggestedGroupsModel = SuggestedGroupsModel()) {
        self.model = model
    }
    
    func fetchJoinableGroups() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userId = try await model.fetchCurrentUserId()
            
            joinableGroups = try await model.fetchJoinableGroups(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching joinable groups: \(error)")
        }
        
        isLoading = false
    }
    
    
    func dismiss() {
        onDismiss?()
    }
    
    func selectGroup(_ group: UserGroup) {
        onGroupSelected?(group)
    }
}
