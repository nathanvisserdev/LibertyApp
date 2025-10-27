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
    
    init(group: UserGroup) {
        _viewModel = StateObject(wrappedValue: GroupDetailViewModel(group: group))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Group Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(viewModel.group.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Image(systemName: viewModel.group.groupType == "PUBLIC" ? "globe" : "lock.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.group.groupType == "PUBLIC" ? .blue : .orange)
                        }
                        
                        if let description = viewModel.group.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(viewModel.group.displayLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Admin Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Admin")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                if let firstName = viewModel.group.admin.firstName, let lastName = viewModel.group.admin.lastName {
                                    Text("\(firstName) \(lastName)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                } else if let firstName = viewModel.group.admin.firstName {
                                    Text(firstName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                
                                Text("@\(viewModel.group.admin.username)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    Spacer()
                }
                .padding()
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
    }
}

#Preview {
    GroupDetailView(group: UserGroup(
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
    ))
}
