
import Foundation
import Combine

@MainActor
final class FollowingListViewModel: ObservableObject {
    
    private let model: FollowingListModel
    private let userId: String
    private let onUserSelected: (String) -> Void
    
    @Published var following: [FollowingUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(model: FollowingListModel = FollowingListModel(),
         userId: String,
         onUserSelected: @escaping (String) -> Void) {
        self.model = model
        self.userId = userId
        self.onUserSelected = onUserSelected
    }
    
    func selectUser(_ userId: String) {
        onUserSelected(userId)
    }
    
    func fetchFollowing() async {
        isLoading = true
        errorMessage = nil
        
        do {
            following = try await model.fetchFollowing(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching following: \(error)")
        }
        
        isLoading = false
    }
}
