//
//  SubnetMenuViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class SubnetMenuViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let model: SubnetMenuModel
    private let subnetService: SubnetSession
    private var cancellables = Set<AnyCancellable>()
    
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
    init(model: SubnetMenuModel = SubnetMenuModel(), subnetService: SubnetSession = SubnetService.shared) {
        self.model = model
        self.subnetService = subnetService
        
        // Subscribe to subnet changes from the service
        subnetService.subnetsDidChange
            .sink { [weak self] in
                self?.refreshSubnets()
            }
            .store(in: &cancellables)
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
    
    func moveSubnet(from source: IndexSet, to destination: Int) {
        // Move in local array
        subnets.move(fromOffsets: source, toOffset: destination)
        
        // Update ordering for all subnets
        Task {
            await updateAllSubnetOrderings()
        }
    }
    
    private func updateAllSubnetOrderings() async {
        // Update ordering for each subnet based on their new position
        for (index, subnet) in subnets.enumerated() {
            do {
                try await model.updateSubnetOrdering(subnetId: subnet.id, ordering: index)
            } catch {
                print("Error updating ordering for subnet \(subnet.name): \(error)")
                // Note: We don't show an alert here to avoid multiple alerts
                // The UI will still show the reordered list even if server update fails
            }
        }
    }
}
