
import SwiftUI

struct AdminSelectionView: View {
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
            mainContent
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
                .onDisappear {
                    viewModel.handleDisappear?()
                }
                .alert("Success", isPresented: $showSuccessAlert) {
                    Button("OK", role: .cancel) {
                        if let groupId = viewModel.createdGroupId {
                            viewModel.onCreateGroupSuccess?(groupId)
                        }
                    }
                } message: {
                    Text(successMessage)
                }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            if viewModel.isLoadingConnections {
                ProgressView("Loading connections...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Form {
                    introductionSection
                    adminsSection
                    if viewModel.selectedAdmins.count > 1 {
                        vicePresidentSection
                    }
                    electionsSection
                    if viewModel.enableElections {
                        electionCycleSection
                    }
                    createButtonSection
                    if let errorMessage = viewModel.errorMessage {
                        errorSection(errorMessage)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var introductionSection: some View {
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
    }
    
    @ViewBuilder
    private var adminsSection: some View {
        Section {
            Text("Select 1-4 connections to be admins to your group.")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            selectedAdminsList
            
            if viewModel.selectedAdmins.isEmpty {
                if viewModel.selectedAdmins.count < 4 {
                    addBoardMemberMenu
                }
            } else {
                moderatorDescription
                if viewModel.selectedAdmins.count < 4 {
                    addBoardMemberMenu
                }
            }
        } header: {
            Text("Admins (\(viewModel.selectedAdmins.count)/4)")
        }
    }
    
    @ViewBuilder
    private var selectedAdminsList: some View {
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
    }
    
    @ViewBuilder
    private var addBoardMemberMenu: some View {
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
    
    @ViewBuilder
    private var moderatorDescription: some View {
        Text(viewModel.requiresApproval 
            ? "**Moderators** can approve join requests, invite new members in and kick problem members out. They can also call for a vote to add or dismiss board members from the round table."
            : "**Moderators** can kick problem members out of the group. They can also call for a vote to add or dismiss a board member from the round table.")
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
    
    @ViewBuilder
    private var vicePresidentSection: some View {
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
    
    @ViewBuilder
    private var electionsSection: some View {
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
    }
    
    @ViewBuilder
    private var electionCycleSection: some View {
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
    
    @ViewBuilder
    private var createButtonSection: some View {
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
    }
    
    @ViewBuilder
    private func errorSection(_ errorMessage: String) -> some View {
        Section {
            Text(errorMessage)
                .font(.callout)
                .foregroundStyle(.red)
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

#Preview {
    let authManager = AuthManager.shared
    let tokenProvider = AuthManager.shared
    let groupService = GroupService()
    let groupInviteService = GroupInviteService()
    let model = CreateGroupModel(TokenProvider: tokenProvider, AuthManagerBadName: authManager)
    let coordinator = CreateGroupCoordinator(
        tokenProvider: tokenProvider,
        authManager: authManager,
        groupService: groupService,
        groupInviteService: groupInviteService
    )
    let viewModel = CreateGroupViewModel(
        model: model,
        groupService: groupService,
        inviteService: groupInviteService,
        coordinator: coordinator
    )
    Task {
        viewModel.name = "Test Group"
        viewModel.selectedGroupPrivacy = .publicGroup
    }
    
    return AdminSelectionView(viewModel: viewModel)
}
