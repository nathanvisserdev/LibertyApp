//
//  TabBarViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-10.
//

import Foundation
import Combine

final class TabBarViewModel: ObservableObject {
    @Published var isShowingCompose: Bool = false
    @Published var isShowingSearch: Bool = false

    func showCompose() { isShowingCompose = true }
    func hideCompose() { isShowingCompose = false }
    func showSearch() { isShowingSearch = true }
    func hideSearch() { isShowingSearch = false }
}
