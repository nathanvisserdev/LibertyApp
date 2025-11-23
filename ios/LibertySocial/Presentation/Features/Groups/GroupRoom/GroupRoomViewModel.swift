
import Foundation
import Combine

@MainActor
final class GroupRoomViewModel: ObservableObject {
    private let model: GroupRoomModel
    private let groupId: String
    @Published var group: UserGroup?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var onDoneTap: (() -> Void)?
    var onFinish: (() -> Void)?
    init(groupId: String, model: GroupRoomModel) {
        self.groupId = groupId
        self.model = model
        
        Task {
            await fetchGroup()
        }
    }
    
    func fetchGroup() async {
        isLoading = true
        errorMessage = nil
        do {
            group = try await model.fetchGroup(groupId: groupId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching group: \(error)")
        }
        isLoading = false
    }
}
