//
//  SubnetViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import Foundation
import Combine

@MainActor
final class SubnetViewModel: ObservableObject {
    @Published var subnet: Subnet?
    @Published var members: [SubnetMember] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showAddMembersSheet: Bool = false
    
    private let model: SubnetModel
    
    init(model: SubnetModel = SubnetModel()) {
        self.model = model
    }
    
    func setSubnet(_ subnet: Subnet) {
        self.subnet = subnet
    }
    
    func fetchMembers() async {
        guard let subnet = subnet else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMembers = try await model.fetchMembers(subnetId: subnet.id)
            members = fetchedMembers
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching subnet members: \(error)")
        }
        
        isLoading = false
    }
    
    func showAddMembers() {
        showAddMembersSheet = true
    }
}
