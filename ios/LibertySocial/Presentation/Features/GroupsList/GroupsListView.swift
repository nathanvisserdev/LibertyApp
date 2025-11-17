
import SwiftUI

struct GroupsListView: View {
    @StateObject private var viewModel: GroupsListViewModel
    
    init(viewModel: GroupsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
            .sheet(isPresented: $viewModel.showCreateGroup) {
                if let makeView = viewModel.makeCreateGroupView {
                    makeView()
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $viewModel.showSuggestedGroups) {
                if let makeView = viewModel.makeSuggestedGroupsView {
                    makeView()
                } else {
                    EmptyView()
                }
            }
            .sheet(item: $viewModel.selectedGroup) { group in
                if let makeView = viewModel.makeGroupView {
                    makeView(group)
                } else {
                    EmptyView()
                }
            }
        }
    }
}//#Preview {
//    let coordinator = GroupsListCoordinator(
//        authManager: AuthManager.shared,
//        tokenProvider: AuthManager.shared
//    )
//    let viewModel = GroupsListViewModel(coordinator: coordinator)
//    return GroupsListView(viewModel: viewModel, coordinator: coordinator)
//}
