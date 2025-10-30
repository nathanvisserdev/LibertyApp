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
    @Published var subnet: SubNet?
    @Published var members: [SubNetMember] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func setSubnet(_ subnet: SubNet) {
        self.subnet = subnet
    }
    
    func fetchMembers() async {
        guard let subnet = subnet else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMembers = try await SubNetModel.fetchMembers(subnetId: subnet.id)
            members = fetchedMembers
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching subnet members: \(error)")
        }
        
        isLoading = false
    }
}
