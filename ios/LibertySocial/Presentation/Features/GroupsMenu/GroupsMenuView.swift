//
//  GroupsMenuView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-31.
//

import SwiftUI

struct GroupsMenuView: View {
    @StateObject private var viewModel: GroupsMenuViewModel
    
    init(viewModel: GroupsMenuViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Create Group option
                Button {
                    viewModel.showCreateGroupView()
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
                
                // Suggested groups option
                Button {
                    viewModel.showSuggestedGroupsView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        Text("Suggested groups")
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
                                viewModel.showGroup(group)
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
            .navigationTitle("Groups")
            .task {
                await viewModel.fetchUserGroups()
            }
            .sheet(isPresented: $viewModel.showCreateGroup) {
                CreateGroupCoordinator().start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showSuggestedGroups) {
                SuggestedGroupsCoordinator().start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $viewModel.selectedGroup) { group in
                GroupCoordinator(group: group).start()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: viewModel.showCreateGroup) { isShowing in
                if !isShowing {
                    // Refresh groups when sheet is dismissed
                    Task {
                        await viewModel.fetchUserGroups()
                    }
                }
            }
        }
    }
}

#Preview {
    GroupsMenuView(viewModel: GroupsMenuViewModel())
}
