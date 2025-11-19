import SwiftUI

enum NextSubnetView {
    case subnetList
    case subnet(Subnet)
    case createSubnet
    case addSubnetMembers(String)
}

@MainActor
final class SubnetsListCoordinator {
    var onFinished: (() -> Void)?
    private let authManager: AuthManaging
    private let tokenProvider: TokenProviding
    private let subnetService: SubnetSession
    private let subnetListView: SubnetsListView
    private let subnetListViewModel: SubnetsListViewModel
    private let createSubnetCoordinator: CreateSubnetCoordinator
    private let addSubnetMembersCoordinator: AddSubnetMembersCoordinator
    private var subnetCoordinator: SubnetCoordinator?

    init(authManager: AuthManaging,
         tokenProvider: TokenProviding,
         subnetService: SubnetSession) {
        self.authManager = authManager
        self.tokenProvider = tokenProvider
        self.subnetService = subnetService
        
        let subnetListModel = SubnetsListModel(
            subnetSession: subnetService,
            TokenProvider: tokenProvider
        )
        let subnetListViewModel = SubnetsListViewModel(
            model: subnetListModel,
            subnetService: subnetService
        )
        self.subnetListViewModel = subnetListViewModel
        self.subnetListView = SubnetsListView(viewModel: subnetListViewModel)
        
        self.createSubnetCoordinator = CreateSubnetCoordinator(
            TokenProvider: tokenProvider,
            subnetService: subnetService,
            subnetListViewModel: subnetListViewModel
        )
        
        self.addSubnetMembersCoordinator = AddSubnetMembersCoordinator(
            subnetId: "",
            TokenProvider: tokenProvider,
            AuthManagerBadName: authManager,
            subnetListViewModel: subnetListViewModel
        )
        
        subnetListViewModel.onNavigate = { [weak self] nextView, subnetId in
            self?.start(nextView: nextView, subnetId: subnetId)
        }
        
        subnetListViewModel.makeCreateSubnetView = { [weak self] in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .createSubnet))
        }
        
        subnetListViewModel.makeSubnetView = { [weak self] subnet in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .subnet(subnet)))
        }
        
        subnetListViewModel.makeAddSubnetMembersView = { [weak self] subnetId in
            guard let self = self else { return AnyView(EmptyView()) }
            return AnyView(self.start(nextView: .addSubnetMembers(subnetId), subnetId: subnetId))
        }
    }

    func start(nextView: NextSubnetView, subnetId: String? = nil) -> some View {
        switch nextView {
        case .subnetList:
            return AnyView(subnetListView)
        case .subnet(let subnet):
            subnetCoordinator = SubnetCoordinator(
                subnet: subnet,
                TokenProvider: tokenProvider,
                AuthManagerBadName: authManager,
                subnetService: subnetService,
                subnetListViewModel: subnetListViewModel
            )
            return AnyView(subnetCoordinator!.start())
        case .createSubnet:
            return AnyView(createSubnetCoordinator.start())
        case .addSubnetMembers(let enumSubnetId):
            return AnyView(addSubnetMembersCoordinator.start(subnetId: subnetId ?? enumSubnetId))
        }
    }
}
