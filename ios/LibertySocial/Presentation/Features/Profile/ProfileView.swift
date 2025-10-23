//
//  ProfileView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    let userId: String
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 100)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.title)
                        .fontWeight(.bold)
                    Text(error)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .padding(.top, 100)
            } else if let profile = viewModel.profile {
                VStack(spacing: 20) {
                    // Profile Photo
                    if let photoURL = profile.photo, let url = URL(string: photoURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                )
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // Name and Username
                    VStack(spacing: 4) {
                        Text("\(profile.firstName) \(profile.lastName)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("@\(profile.username)")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    // Connection Status Badge
                    if let status = profile.connectionStatus {
                        HStack {
                            Image(systemName: connectionIcon(for: status))
                            Text(connectionLabel(for: status))
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                    }
                    
                    // Pending Request Badge
                    if let requestType = profile.requestType {
                        Text("Request Pending (\(requestType))")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(20)
                    }
                    
                    // Connect Button
                    Button(action: {
                        // TODO: Implement connection request
                    }) {
                        Text("Connect with \(profile.firstName)")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Profile Information
                    VStack(alignment: .leading, spacing: 16) {
                        if let about = profile.about {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("About", systemImage: "info.circle")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(about)
                                    .font(.body)
                            }
                        }
                        
                        if let gender = profile.gender {
                            HStack {
                                Label("Gender", systemImage: "person.circle")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(genderLabel(for: gender))
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadProfile(userId: userId)
        }
    }
    
    private func connectionIcon(for status: String) -> String {
        switch status {
        case "ACQUAINTANCE":
            return "person.2.fill"
        case "STRANGER":
            return "person.badge.plus"
        case "IS_FOLLOWING":
            return "star.fill"
        default:
            return "person"
        }
    }
    
    private func connectionLabel(for status: String) -> String {
        switch status {
        case "ACQUAINTANCE":
            return "Acquaintance"
        case "STRANGER":
            return "Stranger"
        case "IS_FOLLOWING":
            return "Following"
        default:
            return status
        }
    }
    
    private func genderLabel(for gender: String) -> String {
        switch gender {
        case "MALE":
            return "Male"
        case "FEMALE":
            return "Female"
        case "NON_BINARY":
            return "Non-binary"
        case "PREFER_NOT_TO_SAY":
            return "Prefer not to say"
        default:
            return gender
        }
    }
}

#Preview {
    NavigationView {
        ProfileView(viewModel: ProfileViewModel(), userId: "1")
    }
}
