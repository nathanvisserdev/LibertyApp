//
//  SelectRoundTableAdminsView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-28.
//

import SwiftUI

struct SelectRoundTableAdminsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CreateGroupViewModel
    @State private var showSuccessAlert = false
    @State private var successMessage = ""
    
    init(viewModel: CreateGroupViewModel) {
        self.viewModel = viewModel
    }
    
    var availableConnections: [Connection] {
        viewModel.connections.filter { connection in
            !viewModel.selectedAdmins.contains(where: { $0.userId == connection.userId })
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoadingConnections {
                    ProgressView("Loading connections...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Form {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Everyone is equal at the round table!")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("but you are the president. Your privileges include breaking ties on a vote, controlling group settings, and approving as well as banning members. You CAN be voted out of administration by the board you now select.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Section {
                            Text("Select 1-4 connections to be admins to your group.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            
                            ForEach(viewModel.connections.filter { connection in
                                viewModel.selectedAdmins.contains(where: { $0.userId == connection.userId })
                            }) { connection in
                                if let admin = viewModel.selectedAdmins.first(where: { $0.userId == connection.userId }) {
                                    selectedAdminRow(admin: admin)
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                viewModel.removeAdmin(admin)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            
                            if viewModel.selectedAdmins.isEmpty {
                                if viewModel.selectedAdmins.count < 4 {
                                    Menu {
                                        ForEach(availableConnections) { connection in
                                            Button(action: {
                                                viewModel.addAdmin(RoundTableAdmin(from: connection))
                                            }) {
                                                HStack {
                                                    Text("\(connection.firstName) \(connection.lastName)")
                                                    Text("@\(connection.username)")
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("Add Board Member", systemImage: "plus.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                    .disabled(availableConnections.isEmpty)
                                }
                            } else {
                                Text(viewModel.requiresApproval 
                                    ? "**Moderators** can approve join requests, invite new members in and kick problem members out. They can also call for a vote to add or dismiss board members from the round table."
                                    : "**Moderators** can kick problem members out of the group. They can also call for a vote to add or dismiss a board member from the round table.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                                
                                if viewModel.selectedAdmins.count < 4 {
                                    Menu {
                                        ForEach(availableConnections) { connection in
                                            Button(action: {
                                                viewModel.addAdmin(RoundTableAdmin(from: connection))
                                            }) {
                                                HStack {
                                                    Text("\(connection.firstName) \(connection.lastName)")
                                                    Text("@\(connection.username)")
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("Add Board Member", systemImage: "plus.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                    .disabled(availableConnections.isEmpty)
                                }
                            }
                        } header: {
                            Text("Admins (\(viewModel.selectedAdmins.count)/4)")
                        }
                        
                        if viewModel.selectedAdmins.count > 1 {
                            Section {
                                Text("Assumes your role should you ever leave.")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                
                                Picker("Vice President", selection: $viewModel.viceChairId) {
                                    Text("Select").tag(nil as String?)
                                    ForEach(viewModel.selectedAdmins) { admin in
                                        Text("\(admin.firstName) \(admin.lastName)")
                                            .tag(admin.userId as String?)
                                    }
                                }
                            } header: {
                                Text("Select Vice President")
                            }
                        }
                        
                        Section {
                            Toggle("Enable Elections", isOn: $viewModel.enableElections)
                        } header: {
                            Text("Go full democracy!")
                        } footer: {
                            if viewModel.enableElections {
                                Text("The whole group will vote for new leadership on the selected cycle duration.")
                                    .font(.caption)
                            }
                        }
                        
                        if viewModel.enableElections {
                            Section {
                                Picker("Election Cycle", selection: $viewModel.selectedElectionCycle) {
                                    Text("3 Months").tag(ElectionCycle.threeMonths)
                                    Text("6 Months").tag(ElectionCycle.sixMonths)
                                    Text("1 Year").tag(ElectionCycle.oneYear)
                                    Text("2 Years").tag(ElectionCycle.twoYears)
                                    Text("4 Years").tag(ElectionCycle.fourYears)
                                }
                                .pickerStyle(.menu)
                            } header: {
                                Text("Cycle Duration")
                            }
                        }
                        
                        Section {
                            Button(action: {
                                Task {
                                    let success = await viewModel.submit()
                                    if success {
                                        successMessage = "\(viewModel.name) group created successfully!"
                                        showSuccessAlert = true
                                    }
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Create Group")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .background(viewModel.canCreateRoundTable && !viewModel.isSubmitting ? Color.blue : Color.gray)
                                .cornerRadius(8)
                            }
                            .disabled(!viewModel.canCreateRoundTable || viewModel.isSubmitting)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Section {
                                Text(errorMessage)
                                    .font(.callout)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Round Table Chairs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchConnections()
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(successMessage)
            }
        }
    }
    
    @ViewBuilder
    private func selectedAdminRow(admin: RoundTableAdmin) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(admin.firstName) \(admin.lastName)")
                    .font(.body)
                Text("@\(admin.username)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if admin.isModerator {
                Text("Moderator")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Toggle("", isOn: Binding(
                get: { admin.isModerator },
                set: { viewModel.toggleModerator(adminId: admin.userId, isModerator: $0) }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// Mock preview
#Preview {
    let viewModel = CreateGroupViewModel()
    viewModel.name = "Test Group"
    viewModel.selectedGroupPrivacy = .publicGroup
    
    return SelectRoundTableAdminsView(viewModel: viewModel)
}
