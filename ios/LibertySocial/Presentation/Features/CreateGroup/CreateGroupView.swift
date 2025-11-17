
import SwiftUI

struct CreateGroupView: View {
    @ObservedObject var viewModel: CreateGroupViewModel
    let coordinator: CreateGroupCoordinator
    @State private var showPersonalGroupAlert = false
    @State private var showPrivateGroupJoinPolicyAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Name", text: $viewModel.name)
                        .autocorrectionDisabled()
                    
                    if viewModel.remainingNameCharacters < 0 {
                        Text("Maximum character count exceeded.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Name")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(GroupPrivacy.allCases, id: \.self) { privacy in
                            Button(action: {
                                viewModel.selectedGroupPrivacy = privacy
                            }) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: viewModel.selectedGroupPrivacy == privacy ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(viewModel.selectedGroupPrivacy == privacy ? .accentColor : .gray)
                                        .imageScale(.large)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(privacy.displayName)
                                            .foregroundColor(.primary)
                                            .font(.body)
                                        
                                        Text(privacy.description)
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Privacy")
                }
                
                Section {
                    Toggle(isOn: Binding(
                        get: { viewModel.selectedGroupType == .roundTable },
                        set: { newValue in
                            if newValue && viewModel.selectedGroupPrivacy == .personalGroup {
                                showPersonalGroupAlert = true
                            } else {
                                viewModel.selectedGroupType = newValue ? .roundTable : .autocratic
                            }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.selectedGroupType == .roundTable ? "Round Table" : "Autocratic")
                                .font(.body)
                            Text(viewModel.selectedGroupType == .roundTable ? "Decisions made democratically by members" : "You have sole administrative control")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Type")
                }
                
                Section {
                    Toggle(isOn: Binding(
                        get: { viewModel.requiresApproval },
                        set: { newValue in
                            if !newValue && viewModel.selectedGroupPrivacy == .privateGroup {
                                showPrivateGroupJoinPolicyAlert = true
                            } else {
                                viewModel.requiresApproval = newValue
                            }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.requiresApproval ? "Requires Approval" : "Open to All")
                                .font(.body)
                            if !viewModel.requiresApproval {
                                Text("Personal rules still apply")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Join Policy")
                }
                
                Section {
                    Button(action: {
                        if viewModel.selectedGroupType == .roundTable {
                            viewModel.onRequestAdminSelection?()
                        } else {
                            Task {
                                await viewModel.submit()
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(viewModel.selectedGroupType == .roundTable ? "Select Board Members" : "Create Group")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(viewModel.isValid && !viewModel.isSubmitting ? Color.blue : Color.gray)
                        .cornerRadius(8)
                    }
                    .disabled(!viewModel.isValid || viewModel.isSubmitting)
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
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.cancel()
                    }
                }
            }
            .disabled(viewModel.isSubmitting)
            .sheet(isPresented: $viewModel.showGroupInvite) {
                if let groupId = viewModel.createdGroupId {
                    viewModel.getGroupInviteView(for: groupId)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .alert("Select public or private for democratic group type.", isPresented: $showPersonalGroupAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Select public or personal to allow open membership.", isPresented: $showPrivateGroupJoinPolicyAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

#Preview {
    let authManager = AuthManager.shared
    let tokenProvider = AuthManager.shared
    let groupsListModel = GroupsListModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
    let groupsListViewModel = GroupsListViewModel(model: groupsListModel, AuthManagerBadName: authManager, groupService: GroupService())
    let coordinator = CreateGroupCoordinator(tokenProvider: tokenProvider, authManager: authManager, groupsListViewModel: groupsListViewModel)
    coordinator.start()
}

