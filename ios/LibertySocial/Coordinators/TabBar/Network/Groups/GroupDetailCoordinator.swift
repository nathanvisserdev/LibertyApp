//
//  GroupDetailCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class GroupDetailCoordinator {
    private let TokenProvider: TokenProviding
    private let AuthManager: AuthManaging
    private let group: UserGroup
    
    init(group: UserGroup,
         TokenProvider: TokenProviding = AuthService.shared,
         AuthManager: AuthManaging = AuthService.shared) {
        self.group = group
        self.TokenProvider = TokenProvider
        self.AuthManager = AuthManager
    }
    
    func start() -> some View {
        let model = GroupDetailModel(TokenProvider: TokenProvider)
        let viewModel = GroupDetailViewModel(groupId: group.id, model: model)
        return GroupDetailView(viewModel: viewModel)
    }
}
