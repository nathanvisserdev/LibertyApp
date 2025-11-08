
import Foundation

struct CurrentUserInfo {
    let photoKey: String?
    let userId: String?
}

struct TabBarModel {
    private let AuthManagerBadName: AuthManaging
    init(AuthManagerBadName: AuthManaging) {
        self.AuthManagerBadName = AuthManagerBadName
    }
    
    func fetchCurrentUserInfo() async throws -> CurrentUserInfo {
        let userInfo = try await AuthManagerBadName.fetchCurrentUser()
        let photoKey = userInfo["profilePhoto"] as? String
        let userId = userInfo["id"] as? String
        return CurrentUserInfo(photoKey: photoKey, userId: userId)
    }
}
