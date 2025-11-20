
import Foundation
import Combine

@MainActor
final class AboutGroupViewModel: ObservableObject {
    @Published var groupDetail: GroupDetail?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isJoining: Bool = false
    @Published var joinSuccessMessage: String?
    
    private let groupId: String
    private let model: AboutGroupModel
    
    init(groupId: String,
         model: AboutGroupModel) {
        self.groupId = groupId
        self.model = model
    }
    
    func fetchGroupDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detail = try await model.fetchGroupDetail(groupId: groupId)
            groupDetail = detail
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching group detail: \(error)")
        }
        
        isLoading = false
    }
    
    func joinGroup() async {
        isJoining = true
        errorMessage = nil
        joinSuccessMessage = nil
        
        do {
            try await model.joinGroup(groupId: groupId)
            joinSuccessMessage = "Join request sent."
            
            await fetchGroupDetail()
        } catch {
            errorMessage = error.localizedDescription
            print("Error joining group: \(error)")
        }
        
        isJoining = false
    }
}
