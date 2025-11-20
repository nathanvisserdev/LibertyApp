
import SwiftUI

struct GroupInviteView: View {
    @ObservedObject var viewModel: GroupInviteViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if viewModel.invitees.isEmpty {
                    emptyStateView
                } else {
                    inviteesList
                }
            }
            .navigationTitle("Invite Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.sendInvites()
                        }
                    } label: {
                        if viewModel.isSendingInvites {
                            ProgressView()
                        } else {
                            Text("Send (\(viewModel.selectedCount))")
                        }
                    }
                    .disabled(!viewModel.canSendInvites)
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .task {
                await viewModel.loadUserPrivacyStatus()
                await viewModel.fetchInvitees()
            }
        }
    }
    
    
    private var inviteesList: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Toggle(isOn: Binding(
                    get: { viewModel.includeAdditional },
                    set: { _ in viewModel.toggleAdditionalFilter() }
                )) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isPrivate ? "person.2" : "person.badge.plus")
                            .foregroundColor(.blue)
                        Text(viewModel.additionalFilterLabel)
                            .font(.body)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                HStack {
                    Button {
                        viewModel.selectAll()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Select All")
                                .font(.footnote)
                        }
                    }
                    .disabled(viewModel.invitees.isEmpty)
                    
                    Spacer()
                    
                    Button {
                        viewModel.deselectAll()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "circle")
                                .font(.caption)
                            Text("Deselect All")
                                .font(.footnote)
                        }
                    }
                    .disabled(viewModel.selectedCount == 0)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            
            Divider()
            
            List {
                ForEach(viewModel.invitees) { invitee in
                    Button {
                        viewModel.toggleSelection(userId: invitee.id)
                    } label: {
                        InviteeRow(
                            invitee: invitee,
                            isSelected: viewModel.isSelected(userId: invitee.id)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No One to Invite")
                .font(.headline)
            Text("All your connections\(viewModel.includeAdditional ? (viewModel.isPrivate ? " and strangers" : " and followers") : "") are already members or have pending invites.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Error")
                .font(.headline)
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                Task {
                    await viewModel.fetchInvitees()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct InviteeRow: View {
    let invitee: InviteeUser
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let photoKey = invitee.profilePhoto, !photoKey.isEmpty {
                ProfilePhotoView(photoKey: photoKey)
                    .frame(width: 50, height: 50)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let firstName = invitee.firstName, let lastName = invitee.lastName {
                    Text("\(firstName) \(lastName)")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Text("@\(invitee.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .blue : .gray.opacity(0.3))
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    let tokenProvider = AuthManager.shared
    let groupService = GroupService()
    let groupInviteService = GroupInviteService()
    let model = GroupInviteModel(TokenProvider: tokenProvider)
    let viewModel = GroupInviteViewModel(
        model: model,
        groupId: "preview-group-id",
        TokenProvider: tokenProvider,
        inviteService: groupInviteService,
        groupService: groupService
    )
    GroupInviteView(viewModel: viewModel)
}
