
import Foundation
import Combine

@MainActor
final class GroupViewModel: ObservableObject {
    
    private let model: GroupModel
    
    @Published var group: UserGroup
    
    var onClose: (() -> Void)?
    
    init(group: UserGroup, model: GroupModel = GroupModel()) {
        self.group = group
        self.model = model
    }
    
    
    
    func close() {
        onClose?()
    }
}
