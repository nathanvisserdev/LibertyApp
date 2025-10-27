//
//  GroupDetailViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation
import Combine

@MainActor
final class GroupDetailViewModel: ObservableObject {
    @Published var group: UserGroup
    
    init(group: UserGroup) {
        self.group = group
    }
}
