
import SwiftUI
import Combine

final class ProfileNavPathStore: ObservableObject {
    @Published var path = NavigationPath()
}

enum ProfileRoute: Hashable {
    case followers(String)
    case following(String)
}

struct ProfileStackView: View {
    @ObservedObject var nav: ProfileNavPathStore
    @StateObject var viewModel: ProfileViewModel
    let userId: String
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        NavigationStack(path: Binding(
            get: { nav.path },
            set: { nav.path = $0 }
        )) {
            ProfileView(
                viewModel: viewModel,
                userId: userId,
                coordinator: coordinator
            )
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .followers(let id):
                    coordinator.makeFollowersCoordinator(for: id)
                        .makeView(onUserSelected: { userId in
                            coordinator.showChildProfile(for: userId)
                        })
                case .following(let id):
                    coordinator.makeFollowingCoordinator(for: id)
                        .makeView(onUserSelected: { userId in
                            coordinator.showChildProfile(for: userId)
                        })
                }
            }
            .sheet(isPresented: $coordinator.isShowingChildProfile) {
                coordinator.makeChildProfileView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

@MainActor
final class ProfileCoordinator: ObservableObject {
    
    private let nav = ProfileNavPathStore()
    
    @Published var isShowingConnect: Bool = false
    @Published var isShowingChildProfile: Bool = false
    
    private var connectCoordinator: ConnectCoordinator?
    private var childProfileCoordinator: ProfileCoordinator?
    
    private var selectedUserId: String?
    
    private let userId: String
    private let authenticationManager: AuthManaging
    private let tokenProvider: TokenProviding

    init(userId: String,
         authenticationManager: AuthManaging,
         tokenProvider: TokenProviding) {
        self.userId = userId
        self.authenticationManager = authenticationManager
        self.tokenProvider = tokenProvider
    }
    
    
    func openFollowers(of userId: String) {
        nav.path.append(ProfileRoute.followers(userId))
    }
    
    func openFollowing(of userId: String) {
        nav.path.append(ProfileRoute.following(userId))
    }
    
    func showChildProfile(for userId: String) {
        selectedUserId = userId
        childProfileCoordinator = ProfileCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
        isShowingChildProfile = true
    }
    
    func showConnect(userId: String, firstName: String, isPrivate: Bool) {
        connectCoordinator = ConnectCoordinator(
            firstName: firstName,
            userId: userId,
            isPrivate: isPrivate,
            TokenProvider: tokenProvider,
            AuthManagerBadName: authenticationManager
        )
        isShowingConnect = true
    }

    func start() -> some View {
        let model = ProfileModel()
        let viewModel = ProfileViewModel(
            model: model,
            makeMediaVM: { key in
                let mediaModel = MediaModel(TokenProvider: self.tokenProvider)
                return MediaViewModel(mediaKey: key, model: mediaModel)
            },
            authenticationManager: authenticationManager,
            onShowFollowers: { [weak self] userId in
                self?.openFollowers(of: userId)
            },
            onShowFollowing: { [weak self] userId in
                self?.openFollowing(of: userId)
            },
            onConnectTapped: { [weak self] userId, firstName, isPrivate in
                self?.showConnect(userId: userId, firstName: firstName, isPrivate: isPrivate)
            }
        )

        return ProfileStackView(
            nav: nav,
            viewModel: viewModel,
            userId: userId,
            coordinator: self
        )
    }
    
    func makeFollowersCoordinator(for userId: String) -> FollowersListCoordinator {
        return FollowersListCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
    }
    
    func makeFollowingCoordinator(for userId: String) -> FollowingListCoordinator {
        return FollowingListCoordinator(
            userId: userId,
            authenticationManager: authenticationManager,
            tokenProvider: tokenProvider
        )
    }
    
    func makeChildProfileView() -> some View {
        guard let coordinator = childProfileCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
    
    func makeConnectView() -> some View {
        guard let coordinator = connectCoordinator else {
            return AnyView(EmptyView())
        }
        return AnyView(coordinator.start())
    }
}
