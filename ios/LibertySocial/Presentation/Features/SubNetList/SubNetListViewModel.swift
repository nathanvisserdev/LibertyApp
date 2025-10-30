//
//  SubNetListViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-29.
//

import Foundation
import Combine

@MainActor
final class SubNetListViewModel: ObservableObject {
    @Published var subNets: [SubNet] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedSubnetId: String?
    
    func fetchSubNets() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let networks = try await SubNetListModel.fetchSubNets()
            subNets = networks
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching subnets: \(error)")
        }
        
        isLoading = false
    }
    
    func selectSubnet(_ subnetId: String) {
        selectedSubnetId = subnetId
    }
    
    func passSubnetIdToViewModel(_ subnetViewModel: SubNetViewModel) {
        guard let subnetId = selectedSubnetId else { return }
        subnetViewModel.setSubnetId(subnetId)
    }
}
