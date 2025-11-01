//
//  FollowingListCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

final class FollowingListCoordinator {
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func start() -> some View {
        let model = FollowingListModel()
        let viewModel = FollowingListViewModel(model: model, userId: userId)
        return FollowingListView(viewModel: viewModel)
    }
}
