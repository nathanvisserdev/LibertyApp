
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
                                    let isSelected = viewModel.selectedGroupPrivacy == privacy
                                    let iconName = isSelected ? "largecircle.fill.circle" : "circle"
                                    let iconColor = isSelected ? Color.accentColor : Color.gray
                                    
                                    Image(systemName: iconName)
                                        .foregroundColor(iconColor)
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
                    let groupTypeBinding = Binding<Bool>(
                        get: { viewModel.selectedGroupType == .roundTable },
                        set: { newValue in
                            if newValue && viewModel.selectedGroupPrivacy == .personalGroup {
                                showPersonalGroupAlert = true
                            } else {
                                viewModel.selectedGroupType = newValue ? .roundTable : .autocratic
                            }
                        }
                    )
                    
                    Toggle(isOn: groupTypeBinding) {
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
                    let joinPolicyBinding = Binding<Bool>(
                        get: { viewModel.requiresApproval },
                        set: { newValue in
                            if !newValue && viewModel.selectedGroupPrivacy == .privateGroup {
                                showPrivateGroupJoinPolicyAlert = true
                            } else {
                                viewModel.requiresApproval = newValue
                            }
                        }
                    )
                    
                    Toggle(isOn: joinPolicyBinding) {
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
                        .background({
                            let isEnabled = viewModel.isValid && !viewModel.isSubmitting
                            return isEnabled ? Color.blue : Color.gray
                        }())
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
    let groupService = GroupService()
    let groupInviteService = GroupInviteService()
    let groupsListModel = GroupsListModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
    let groupsListViewModel = GroupsListViewModel(model: groupsListModel, AuthManagerBadName: authManager, groupService: groupService)
    let coordinator = CreateGroupCoordinator(
        tokenProvider: tokenProvider,
        authManager: authManager,
        groupService: groupService,
        groupInviteService: groupInviteService
    )
    coordinator.start()
}

