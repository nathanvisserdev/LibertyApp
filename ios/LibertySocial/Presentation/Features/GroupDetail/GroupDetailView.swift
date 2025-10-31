//
//  GroupDetailView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-27.
//

import SwiftUI

struct GroupDetailView: View {
    @StateObject private var viewModel: GroupDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: GroupDetailViewModel) {
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
                            // Success Message
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
                            
                            // Join Group Button
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
                            
                            // Group Information Section
                            VStack(alignment: .leading, spacing: 16) {
                                // Group Header
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(groupDetail.name)
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        Text(groupDetail.displayLabel)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: groupDetail.groupType == "PUBLIC" ? "globe" : "lock.fill")
                                        .font(.title2)
                                        .foregroundColor(groupDetail.groupType == "PUBLIC" ? .blue : .orange)
                                }
                                
                                if let description = groupDetail.description, !description.isEmpty {
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                
                                Divider()
                                
                                // Group Stats
                                HStack(spacing: 30) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Members")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(groupDetail.memberCount)")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Created")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(formatDate(groupDetail.createdAt))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                                
                                Divider()
                                
                                // Admin Section
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
                                            }
                                            
                                            Text("@\(groupDetail.admin.username)")
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
                            
                            // Members Section
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
                                            
                                            if member.id != groupDetail.members.last?.id {
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
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.fetchGroupDetail()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Member Row
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
                } else {
                    Text(member.user.username)
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Text("@\(member.user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
    let model = GroupDetailModel()
    let viewModel = GroupDetailViewModel(groupId: group.id, model: model)
    return GroupDetailView(viewModel: viewModel)
}
