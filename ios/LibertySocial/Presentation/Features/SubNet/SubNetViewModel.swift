//
//  SubNetViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation
import Combine

@MainActor
final class SubNetViewModel: ObservableObject {
    @Published var subnetId: String?
    
    func setSubnetId(_ id: String) {
        self.subnetId = id
    }
}
