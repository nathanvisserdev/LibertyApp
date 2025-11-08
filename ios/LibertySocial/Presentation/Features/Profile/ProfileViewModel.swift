
import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    private let model: ProfileModel
    private let makeMediaVM: (String) -> MediaViewModel
    private let authenticationManager: AuthManaging
    
    private let onShowFollowers: (String) -> Void
    private let onShowFollowing: (String) -> Void
    private let onConnectTapped: (String, String, Bool) -> Void

    @Published var profile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOwnProfile: Bool = false

    init(
        model: ProfileModel,
        makeMediaVM: @escaping (String) -> MediaViewModel,
        authenticationManager: AuthManaging,
        onShowFollowers: @escaping (String) -> Void,
        onShowFollowing: @escaping (String) -> Void,
        onConnectTapped: @escaping (String, String, Bool) -> Void
    ) {
        self.model = model
        self.makeMediaVM = makeMediaVM
        self.authenticationManager = authenticationManager
        self.onShowFollowers = onShowFollowers
        self.onShowFollowing = onShowFollowing
        self.onConnectTapped = onConnectTapped
    }

    func makeMediaViewModel(for mediaKey: String) -> MediaViewModel {
        makeMediaVM(mediaKey)
    }

    
    func showFollowers(userId: String) {
        onShowFollowers(userId)
    }
    
    func showFollowing(userId: String) {
        onShowFollowing(userId)
    }
    
    func connect(userId: String, firstName: String, isPrivate: Bool) {
        onConnectTapped(userId, firstName, isPrivate)
    }
    
    func loadProfile(userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            profile = try await model.fetchUserProfile(userId: userId)
            isOwnProfile = await checkIfOwnProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func checkIfOwnProfile(userId: String) async -> Bool {
        do {
            let currentUser = try await authenticationManager.fetchCurrentUserTyped()
            return currentUser.id == userId
        } catch {
            print("❌ Failed to check if own profile: \(error)")
            return false
        }
    }
}
