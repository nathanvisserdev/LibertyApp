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
    
    // MARK: - Published (UI State for Alerts)
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var alertMessage: String = ""
    
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
    
    func deleteSubnet(_ subnet: Subnet) async {
        do {
            try await model.deleteSubnet(subnetId: subnet.id)
            
            // Remove from local array
            subnets.removeAll { $0.id == subnet.id }
            
            // Show success alert
            alertMessage = "'\(subnet.name)' deleted successfully"
            showSuccessAlert = true
        } catch {
            // Show error alert
            alertMessage = error.localizedDescription
            showErrorAlert = true
            print("Error deleting subnet: \(error)")
        }
    }
}
