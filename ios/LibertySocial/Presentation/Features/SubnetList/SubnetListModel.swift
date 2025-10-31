//
//  SubnetListModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation

// MARK: - API
struct SubnetListModel {
    
    private let subnetSession: SubnetSession
    
    init(subnetSession: SubnetSession = SubnetService.shared) {
        self.subnetSession = subnetSession
    }
    
    func fetchSubnets() async throws -> [Subnet] {
        return try await subnetSession.getUserSubnets()
    }
}
