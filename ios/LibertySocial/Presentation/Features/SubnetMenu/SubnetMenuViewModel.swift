//
//  SubnetMenuViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import Combine

@MainActor
final class SubnetMenuViewModel: ObservableObject {
    
    // MARK: - Published (UI State for Navigation)
    @Published var showCreateSubnet: Bool = false
    @Published var showSubnetView: Bool = false
    
    // MARK: - Init
    init() {
        // Initialize with dependencies if needed
    }
    
    // MARK: - Intents (User Actions)
    func showCreateSubnetView() {
        showCreateSubnet = true
    }
    
    func hideCreateSubnetView() {
        showCreateSubnet = false
    }
    
    func showSubnet() {
        showSubnetView = true
    }
    
    func hideSubnet() {
        showSubnetView = false
    }
}
