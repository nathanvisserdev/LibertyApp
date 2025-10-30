//
//  NetworkView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-26.
//

import SwiftUI

struct NetworkView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NetworkViewModel()
    @StateObject private var subNetViewModel = SubNetListViewModel()
    @State private var showConnections = false
    @State private var showCreateGroup = false
    @State private var showGroupsWithMutuals = false
    @State private var selectedGroup: UserGroup?
    @State private var selectedSubNet: SubNet?
    
    var body: some View {
        NavigationStack {
            List {
                // Create Group option
                Button {
                    showCreateGroup = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Create Group")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                
                // Join Group option
                Button {
                    showGroupsWithMutuals = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        Text("Join Group")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                
                // Connections Section
                Button {
                    showConnections = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Connections")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("View your connections")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                
                Section {
                    if subNetViewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else if let errorMessage = subNetViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else if subNetViewModel.subNets.isEmpty {
                        Text("No subnets yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(subNetViewModel.subNets) { subnet in
                            Button {
                                selectedSubNet = subnet
                            } label: {
                                HStack(spacing: 12) {
                                    // Icon based on visibility or default status
                                    Image(systemName: subnet.isDefault ? "star.circle.fill" : visibilityIcon(for: subnet.visibility))
                                        .font(.title2)
                                        .foregroundColor(subnet.isDefault ? .yellow : visibilityColor(for: subnet.visibility))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(subnet.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        if let description = subnet.description, !description.isEmpty {
                                            Text(description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        // Show member/post counts
                                        HStack(spacing: 8) {
                                            Label("\(subnet.memberCount)", systemImage: "person.2")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            
                                            Label("\(subnet.postCount)", systemImage: "doc.text")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("SubNets")
                }
                
                Section {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else if viewModel.userGroups.isEmpty {
                        Text("No other groups yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.userGroups) { group in
                            Button {
                                selectedGroup = group
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: group.groupType == "PUBLIC" ? "globe" : "lock.fill")
                                        .font(.title2)
                                        .foregroundColor(group.groupType == "PUBLIC" ? .blue : .orange)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(group.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        if let description = group.description, !description.isEmpty {
                                            Text(description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if group.isHidden {
                                        Image(systemName: "eye.slash.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("My Groups")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Network")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchUserGroups()
                await subNetViewModel.fetchSubNets()
            }
            .sheet(isPresented: $showConnections) {
                ConnectionsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showGroupsWithMutuals) {
                GroupsWithMutualsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedGroup) { group in
                GroupView(group: group)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: showCreateGroup) { isShowing in
                if !isShowing {
                    // Refresh groups when sheet is dismissed
                    Task {
                        await viewModel.fetchUserGroups()
                    }
                }
            }
        }
    }
    
    // Helper functions for subnet visibility icons/colors
    private func visibilityIcon(for visibility: String) -> String {
        switch visibility {
        case "PUBLIC":
            return "globe"
        case "CONNECTIONS":
            return "person.2.fill"
        case "ACQUAINTANCES":
            return "person.fill"
        case "PRIVATE":
            return "lock.fill"
        default:
            return "lock.fill"
        }
    }
    
    private func visibilityColor(for visibility: String) -> Color {
        switch visibility {
        case "PUBLIC":
            return .blue
        case "CONNECTIONS":
            return .green
        case "ACQUAINTANCES":
            return .orange
        case "PRIVATE":
            return .purple
        default:
            return .purple
        }
    }
}

#Preview {
    NetworkView()
}
