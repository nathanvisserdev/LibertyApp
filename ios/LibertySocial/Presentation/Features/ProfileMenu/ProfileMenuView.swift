//
//  ProfileMenuView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-28.
//

import SwiftUI

struct ProfileMenuView: View {
    @StateObject private var viewModel: ProfileMenuViewModel
    @Environment(\.dismiss) var dismiss
    let userId: String?
    
    init(viewModel: ProfileMenuViewModel, userId: String?) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.userId = userId
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Profile option
                Button {
                    viewModel.tapProfile()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Profile")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("View profile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                
                // Settings option
                Button {
                    viewModel.tapSettings()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Settings")
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
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showProfile) {
                if let userId = userId {
                    ProfileView(viewModel: ProfileViewModel(), userId: userId)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}

#Preview {
    ProfileMenuCoordinator().start(userId: "sample-user-id")
}
