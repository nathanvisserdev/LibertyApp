
import Foundation
import Combine

@MainActor
final class GroupRoomViewModel: ObservableObject {
    
    private let model: GroupRoomModel
    
    @Published var group: UserGroup
    
    var onClose: (() -> Void)?
    
    init(group: UserGroup, model: GroupRoomModel) {
        self.group = group
        self.model = model
    }
    
    
    
    func close() {
        onClose?()
    }
}
