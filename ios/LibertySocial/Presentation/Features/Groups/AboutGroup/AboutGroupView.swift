
import SwiftUI

struct AboutGroupView: View {
    @StateObject private var viewModel: AboutGroupViewModel
    
    init(viewModel: AboutGroupViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Text("Loading group details...")
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
                                await viewModel.fetchGroupDetail()
                            }
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 16)
                        Spacer()
                    }
                } else if let groupDetail = viewModel.groupDetail {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if let successMessage = viewModel.joinSuccessMessage {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(successMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                            
                            if !groupDetail.isMember {
                                Button {
                                    Task {
                                        await viewModel.joinGroup()
                                    }
                                } label: {
                                    HStack {
                                        if viewModel.isJoining {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Text("Joining...")
                                                .fontWeight(.semibold)
                                        } else {
                                            Image(systemName: "person.badge.plus")
                                            Text("Join Group")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.isJoining ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(viewModel.isJoining)
                                .padding(.horizontal)
                            }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(groupDetail.name)
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: groupDetail.groupType == "PUBLIC" ? "globe" : "lock.fill")
                                                .font(.caption)
                                            Text(groupDetail.groupType.capitalized)
                                                .font(.caption)
                                            Text("•")
                                                .font(.caption)
                                            Text(groupDetail.groupPrivacy.capitalized)
                                                .font(.caption)
                                        }
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                if let description = groupDetail.description, !description.isEmpty {
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Members")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(groupDetail.memberCount)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Admin")
                                        .font(.headline)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "person.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            if let firstName = groupDetail.admin.firstName, let lastName = groupDetail.admin.lastName {
                                                Text("\(firstName) \(lastName)")
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                            } else if let firstName = groupDetail.admin.firstName {
                                                Text(firstName)
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                            } else {
                                                Text("Group Admin")
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                            }
                                            
                                            Text("Admin")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Members (\(groupDetail.memberCount))")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if groupDetail.memberVisibility == "HIDDEN" {
                                    VStack(spacing: 8) {
                                        Image(systemName: "eye.slash")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("Member list is hidden")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 30)
                                } else if groupDetail.members.isEmpty {
                                    Text("No members to display")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 20)
                                } else {
                                    VStack(spacing: 0) {
                                        ForEach(groupDetail.members) { member in
                                            MemberRow(member: member)
                                            
                                            if member.groupMembershipId != groupDetail.members.last?.groupMembershipId {
                                                Divider()
                                                    .padding(.leading, 60)
                                            }
                                        }
                                    }
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Group Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.handleDoneTap?()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchGroupDetail()
        }
        .onDisappear { viewModel.handleDisappear?() }
    }
}

struct MemberRow: View {
    let member: GroupMember
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 2) {
                if let firstName = member.user.firstName, let lastName = member.user.lastName {
                    Text("\(firstName) \(lastName)")
                        .font(.body)
                        .fontWeight(.medium)
                } else if let firstName = member.user.firstName {
                    Text(firstName)
                        .font(.body)
                        .fontWeight(.medium)
                } else if let username = member.user.username {
                    Text(username)
                        .font(.body)
                        .fontWeight(.medium)
                } else {
                    Text("Member")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                if let username = member.user.username {
                    Text("@\(username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("Joined \(formatJoinDate(member.joinedAt))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatJoinDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let group = UserGroup(
        id: "1",
        name: "Sample Group",
        description: "This is a sample group description",
        groupType: "PUBLIC",
        isHidden: false,
        adminId: "admin1",
        admin: GroupAdmin(
            id: "admin1",
            username: "johndoe",
            firstName: "John",
            lastName: "Doe"
        ),
        displayLabel: "Sample Group public assembly room",
        joinedAt: Date()
    )
    let tokenProvider = AuthManager()
    let groupService = GroupService(TokenProvider: tokenProvider)
    let model = AboutGroupModel(groupService: groupService)
    let viewModel = AboutGroupViewModel(groupId: group.id, model: model)
    AboutGroupView(viewModel: viewModel)
}
