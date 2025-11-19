
import Foundation
import Combine

@MainActor
final class AssemblyRoomViewModel: ObservableObject {
    
    private let model: AssemblyRoomModel
    
    @Published var group: UserGroup
    
    var onClose: (() -> Void)?
    
    init(group: UserGroup, model: AssemblyRoomModel) {
        self.group = group
        self.model = model
    }
    
    
    
    func close() {
        onClose?()
    }
}
