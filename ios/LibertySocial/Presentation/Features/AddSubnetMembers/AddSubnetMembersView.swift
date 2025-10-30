//
//  AddSubnetMembersView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-30.
//

import SwiftUI

struct AddSubnetMembersView: View {
    @StateObject private var viewModel = AddSubnetMembersViewModel()
    let subnetId: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading connections...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            Task {
                                await viewModel.fetchEligibleConnections()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.eligibleConnections.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No Eligible Connections")
                            .font(.headline)
                        Text("All your connections are already members of this subnet")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    connectionsList
                }
            }
            .navigationTitle("Add Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add (\(viewModel.selectedUserIds.count))") {
                        // TODO: Add members
                        dismiss()
                    }
                    .disabled(viewModel.selectedUserIds.isEmpty)
                }
            }
            .onAppear {
                viewModel.setSubnetId(subnetId)
                Task {
                    await viewModel.fetchEligibleConnections()
                }
            }
        }
    }
    
    private var connectionsList: some View {
        List {
            ForEach(viewModel.eligibleConnections) { connection in
                Button {
                    viewModel.toggleSelection(userId: connection.userId)
                } label: {
                    HStack(spacing: 12) {
                        // Profile Photo
                        if let photoKey = connection.profilePhoto, !photoKey.isEmpty {
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
                            Text("\(connection.firstName) \(connection.lastName)")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("@\(connection.username)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: viewModel.isSelected(userId: connection.userId) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.isSelected(userId: connection.userId) ? .blue : .gray.opacity(0.3))
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    AddSubnetMembersView(subnetId: "preview-subnet-id")
}
