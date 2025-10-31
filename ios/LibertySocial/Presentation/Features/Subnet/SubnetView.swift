//
//  SubnetView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import SwiftUI

struct SubnetView: View {
    @StateObject private var viewModel: SubnetViewModel
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    init(viewModel: SubnetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let subnet = viewModel.subnet {
                    if viewModel.members.isEmpty {
                        emptyMembersView(subnet: subnet)
                    } else {
                        membersListView(subnet: subnet)
                    }
                } else {
                    Text("No subnet selected")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(viewModel.subnet?.name ?? "Subnet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showAddMembers()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddMembersSheet) {
                if let subnetId = viewModel.subnet?.id {
                    let coordinator = AddSubnetMembersCoordinator(subnetId: subnetId) {
                        Task {
                            await viewModel.fetchMembers()
                        }
                    }
                    coordinator.start()
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchMembers()
                }
            }
        }
    }
    
    private func emptyMembersView(subnet: Subnet) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Subnet info
            VStack(spacing: 8) {
                Text(subnet.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("empty")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Add members prompt
            VStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Add members now")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .onTapGesture {
                viewModel.showAddMembers()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func membersListView(subnet: Subnet) -> some View {
        List {
            // Subnet Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(subnet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let description = subnet.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        Label(visibilityLabel(for: subnet.visibility), systemImage: visibilityIcon(for: subnet.visibility))
                            .font(.caption)
                            .foregroundColor(visibilityColor(for: subnet.visibility))
                        
                        if subnet.isDefault {
                            Label("Default", systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Members Section
            Section(header: Text("Members (\(viewModel.members.count))")) {
                ForEach(viewModel.members) { member in
                    HStack(spacing: 12) {
                        // Profile Photo
                        if let photoKey = member.user.profilePhoto, !photoKey.isEmpty {
                            ProfilePhotoView(photoKey: photoKey)
                                .frame(width: 40, height: 40)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let firstName = member.user.firstName, let lastName = member.user.lastName {
                                Text("\(firstName) \(lastName)")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            
                            Text("@\(member.user.username)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(member.role.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(roleColor(for: member.role).opacity(0.2))
                            .foregroundColor(roleColor(for: member.role))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    let member = viewModel.members[index]
                    
                    Task {
                        let result = await viewModel.deleteMember(member)
                        alertTitle = result.success ? "Success" : "Error"
                        alertMessage = result.message
                        showAlert = true
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Helper functions
    private func visibilityIcon(for visibility: String) -> String {
        switch visibility {
        case "PUBLIC": return "globe"
        case "CONNECTIONS": return "person.2.fill"
        case "ACQUAINTANCES": return "person.fill"
        case "PRIVATE": return "lock.fill"
        default: return "lock.fill"
        }
    }
    
    private func visibilityColor(for visibility: String) -> Color {
        switch visibility {
        case "PUBLIC": return .blue
        case "CONNECTIONS": return .green
        case "ACQUAINTANCES": return .orange
        case "PRIVATE": return .purple
        default: return .purple
        }
    }
    
    private func visibilityLabel(for visibility: String) -> String {
        switch visibility {
        case "PUBLIC": return "Public"
        case "CONNECTIONS": return "Connections"
        case "ACQUAINTANCES": return "Acquaintances"
        case "PRIVATE": return "Private"
        default: return visibility.capitalized
        }
    }
    
    private func roleColor(for role: String) -> Color {
        switch role.uppercased() {
        case "OWNER": return .purple
        case "MANAGER": return .red
        case "CONTRIBUTOR": return .orange
        case "VIEWER": return .blue
        default: return .gray
        }
    }
}
