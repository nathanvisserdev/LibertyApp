//
//  GroupDetailCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-01-28.
//

import SwiftUI

final class GroupDetailCoordinator {
    private let authSession: AuthSession
    private let authService: AuthServiceProtocol
    private let group: UserGroup
    
    init(group: UserGroup,
         authSession: AuthSession = AuthService.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.group = group
        self.authSession = authSession
        self.authService = authService
    }
    
    func start() -> some View {
        let model = GroupDetailModel(authSession: authSession)
        let viewModel = GroupDetailViewModel(groupId: group.id, model: model)
        return GroupDetailView(viewModel: viewModel)
    }
}
