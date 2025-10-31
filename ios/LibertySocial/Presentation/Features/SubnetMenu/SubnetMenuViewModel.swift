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
    
    // MARK: - Dependencies
    private let model: SubnetMenuModel
    
    // MARK: - Published (Output State)
    @Published var subnets: [Subnet] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Published (UI State for Navigation)
    @Published var showCreateSubnet: Bool = false
    @Published var showSubnetView: Bool = false
    @Published var selectedSubnet: Subnet?
    
    // MARK: - Init
    init(model: SubnetMenuModel = SubnetMenuModel()) {
        self.model = model
    }
    
    // MARK: - Intents (User Actions)
    func fetchSubnets() async {
        isLoading = true
        errorMessage = nil
        
        do {
            subnets = try await model.fetchSubnets()
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching subnets: \(error)")
        }
        
        isLoading = false
    }
    
    func showCreateSubnetView() {
        showCreateSubnet = true
    }
    
    func hideCreateSubnetView() {
        showCreateSubnet = false
    }
    
    func showSubnet(_ subnet: Subnet) {
        selectedSubnet = subnet
        showSubnetView = true
    }
    
    func hideSubnet() {
        selectedSubnet = nil
        showSubnetView = false
    }
    
    func refreshSubnets() {
        Task {
            await fetchSubnets()
        }
    }
}
