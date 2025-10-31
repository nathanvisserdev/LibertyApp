//
//  SearchCoordinator.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

/// Stateless coordinator for Search flow - navigation is SwiftUI-owned
final class SearchCoordinator {
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Start
    /// Builds the SearchView with its ViewModel
    func start() -> some View {
        let viewModel = SearchViewModel()
        return SearchView(viewModel: viewModel)
    }
}
