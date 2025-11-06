//
//  SuggestedGroupsView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import SwiftUI

struct SuggestedGroupsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: SuggestedGroupsViewModel
    @State private var selectedGroup: UserGroup?
    
    init(viewModel: SuggestedGroupsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Text("Loading groups...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        Spacer()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                            .padding(.top, 8)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            Task {
                                await viewModel.fetchJoinableGroups()
                            }
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 16)
                        Spacer()
                    }
                } else if viewModel.joinableGroups.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "person.2.slash")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No Groups Available")
                            .font(.headline)
                            .padding(.top, 8)
                        Text("You don't have any groups from your connections yet.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.joinableGroups) { group in
                            Button {
                                viewModel.selectGroup(group)
                            } label: {
                                GroupRow(group: group)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Suggested groups")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchJoinableGroups()
            }
            .sheet(item: $selectedGroup) { group in
                let coordinator = GroupDetailCoordinator(group: group)
                coordinator.start()
            }
        }
    }
}

// MARK: - Group Row
struct GroupRow: View {
    let group: UserGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                    
                    if let description = group.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: group.groupType == "PUBLIC" ? "globe" : "lock.fill")
                    .font(.title3)
                    .foregroundColor(group.groupType == "PUBLIC" ? .blue : .orange)
            }
            
            // Admin information
            HStack(spacing: 4) {
                Image(systemName: "person.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Admin: \(adminDisplayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
    
    private var adminDisplayName: String {
        if let firstName = group.admin.firstName, let lastName = group.admin.lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = group.admin.firstName {
            return firstName
        } else {
            return group.admin.username
        }
    }
}

#Preview {
    SuggestedGroupsView(viewModel: SuggestedGroupsViewModel())
}
