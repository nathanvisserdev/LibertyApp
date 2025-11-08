
import SwiftUI

struct GroupsMenuView: View {
    @StateObject private var viewModel: GroupsMenuViewModel
    @ObservedObject private var coordinator: GroupsMenuCoordinator
    
    init(viewModel: GroupsMenuViewModel, coordinator: GroupsMenuCoordinator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.coordinator = coordinator
    }
    
    var body: some View {
        NavigationStack {
            List {
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
            .sheet(isPresented: $coordinator.showCreateGroup) {
                coordinator.makeCreateGroupView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $coordinator.showSuggestedGroups) {
                coordinator.makeSuggestedGroupsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $coordinator.selectedGroup) { group in
                coordinator.makeGroupView(for: group)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    let coordinator = GroupsMenuCoordinator(
        authManager: AuthManager.shared,
        tokenProvider: AuthManager.shared
    )
    let viewModel = GroupsMenuViewModel(coordinator: coordinator)
    return GroupsMenuView(viewModel: viewModel, coordinator: coordinator)
}
