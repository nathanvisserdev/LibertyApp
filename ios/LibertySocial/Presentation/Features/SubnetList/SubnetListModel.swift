
import Foundation

struct SubnetListModel {
    
    private let subnetSession: SubnetSession
    
    init(subnetSession: SubnetSession = SubnetService.shared) {
        self.subnetSession = subnetSession
    }
    
    func fetchSubnets() async throws -> [Subnet] {
        return try await subnetSession.getUserSubnets()
    }
}
