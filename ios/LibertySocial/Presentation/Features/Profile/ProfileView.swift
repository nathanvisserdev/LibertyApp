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
    @State private var showConnectionTypeSelection = false
    
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
                    if let photoKey = profile.profilePhoto, !photoKey.isEmpty {
                        let _ = print("📸 ProfileView: Photo key from profile: \(photoKey)")
                        ProfilePhotoView(photoKey: photoKey)
                    } else {
                        let _ = print("📸 ProfileView: No profilePhoto key in profile")
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
                        
                        // Public/Private Badge
                        HStack(spacing: 4) {
                            Image(systemName: profile.isPrivate ? "lock.fill" : "globe")
                            Text(profile.isPrivate ? "Private User" : "Public User")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(profile.isPrivate ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                        .foregroundColor(profile.isPrivate ? .purple : .blue)
                        .cornerRadius(20)
                        .padding(.top, 4)
                        
                        // Follower/Following counts
                        if let followerCount = profile.followerCount,
                           let followingCount = profile.followingCount {
                            HStack(spacing: 20) {
                                // Followers (tappable if user is public)
                                if !profile.isPrivate {
                                    NavigationLink(destination: {
                                        let coordinator = FollowersListCoordinator(userId: userId)
                                        coordinator.start()
                                    }) {
                                        VStack(spacing: 2) {
                                            Text("\(followerCount)")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                            Text("Followers")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                } else {
                                    VStack(spacing: 2) {
                                        Text("\(followerCount)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text("Followers")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Following (tappable if user is public)
                                if !profile.isPrivate {
                                    NavigationLink(destination: {
                                        let coordinator = FollowingListCoordinator(userId: userId)
                                        coordinator.start()
                                    }) {
                                        VStack(spacing: 2) {
                                            Text("\(followingCount)")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                            Text("Following")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                } else {
                                    VStack(spacing: 2) {
                                        Text("\(followingCount)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text("Following")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    // "Follows you" badge
                    if let isFollowingYou = profile.isFollowingYou, isFollowingYou {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Follows you")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(20)
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
                    
                    // Connect Button (only show if not viewing own profile)
                    if !viewModel.isOwnProfile {
                        Button(action: {
                            showConnectionTypeSelection = true
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
                        .sheet(isPresented: $showConnectionTypeSelection) {
                            let coordinator = ConnectCoordinator(firstName: profile.firstName, userId: userId, isPrivate: profile.isPrivate)
                            coordinator.start()
                        }
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Profile Information
                    VStack(alignment: .leading, spacing: 16) {
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
                        
                        if let about = profile.about {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("About", systemImage: "info.circle")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(about)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Posts Section
                    if let posts = profile.posts, !posts.isEmpty {
                        Divider()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Posts", systemImage: "square.and.pencil")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            
                            ForEach(posts, id: \.id) { post in
                                VStack(alignment: .leading, spacing: 6) {
                                    // Display media if available
                                    if let mediaKey = post.media {
                                        MediaImageView(
                                            viewModel: viewModel.makeMediaViewModel(for: mediaKey),
                                            orientation: post.orientation
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.horizontal, 20)
                                    }
                                    
                                    // Display content if available
                                    if let content = post.content {
                                        Text(content)
                                            .font(.body)
                                            .padding(.horizontal, 20)
                                    }
                                    
                                    Text(DateFormatters.string(fromISO: post.createdAt))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 20)
                                }
                                .padding(.vertical, 8)
                                
                                if post.id != posts.last?.id {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
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
