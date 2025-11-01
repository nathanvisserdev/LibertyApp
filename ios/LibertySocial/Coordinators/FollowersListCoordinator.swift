//
//  FollowersListCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

final class FollowersListCoordinator {
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func start() -> some View {
        let model = FollowersListModel()
        let viewModel = FollowersListViewModel(model: model, userId: userId)
        return FollowersListView(viewModel: viewModel)
    }
}
