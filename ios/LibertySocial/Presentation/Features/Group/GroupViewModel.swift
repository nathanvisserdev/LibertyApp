//
//  GroupViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import Foundation
import Combine

@MainActor
final class GroupViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: GroupModel
    
    // MARK: - Published (State)
    @Published var group: UserGroup
    
    // MARK: - Callbacks
    var onClose: (() -> Void)?
    
    // MARK: - Init
    init(group: UserGroup, model: GroupModel = GroupModel()) {
        self.group = group
        self.model = model
    }
    
    // MARK: - Intents (User Actions)
    // Future: Add methods for group actions (join, leave, post, etc.)
    
    // MARK: - Actions
    
    func close() {
        onClose?()
    }
}
