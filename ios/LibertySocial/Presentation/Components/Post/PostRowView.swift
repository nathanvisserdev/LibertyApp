//
//  PostRowView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-03.
//

import SwiftUI
import Combine

struct PostRowView: View {
    let post: PostItem
    let currentUserId: String?
    let showMenu: Bool
    let makeMediaVM: (String) -> MediaViewModel
    let onOpen: (() -> Void)?
    
    init(post: PostItem, 
         currentUserId: String?, 
         showMenu: Bool,
         makeMediaVM: @escaping (String) -> MediaViewModel,
         onOpen: (() -> Void)? = nil) {
        self.post = post
        self.currentUserId = currentUserId
        self.showMenu = showMenu
        self.makeMediaVM = makeMediaVM
        self.onOpen = onOpen
    }
    
    // MARK: - Computed Properties
    private var isCurrentUsersPost: Bool {
        guard let currentUserId = currentUserId else { return false }
        return post.userId == currentUserId
    }
    
    private var authorDisplayName: String {
        "\(post.user.firstName) \(post.user.lastName)"
    }
    
    private var authorUsername: String {
        "@\(post.user.username)"
    }
    
    private var formattedDate: String {
        DateFormatter.feed.string(fromISO: post.createdAt)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Author header
            HStack {
                Text("\(authorDisplayName) (\(authorUsername))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if showMenu && isCurrentUsersPost {
                    Image(systemName: "ellipsis")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Media if available
            if let mediaKey = post.media {
                MediaImageView(
                    viewModel: makeMediaVM(mediaKey),
                    orientation: post.orientation
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Content if available
            if let content = post.content {
                Text(content)
                    .font(.body)
            }
            
            // Timestamp
            Text(formattedDate)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onOpen?()
        }
    }
}

// MARK: - MediaImageView
struct MediaImageView: View {
    @ObservedObject var viewModel: MediaViewModel
    let orientation: String?
    
    init(viewModel: MediaViewModel, orientation: String?) {
        self.viewModel = viewModel
        self.orientation = orientation
    }
    
    var body: some View {
        Group {
            if let url = viewModel.presignedURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    case .failure(let error):
                        let _ = print("📸 MediaImageView: AsyncImage failed to load from URL: \(url)")
                        let _ = print("📸 MediaImageView: Error: \(error.localizedDescription)")
                        Rectangle()
                            .fill(.secondary.opacity(0.2))
                            .overlay(
                                VStack {
                                    Text("Failed to load image").font(.caption).foregroundStyle(.secondary)
                                    Text(error.localizedDescription).font(.caption2).foregroundStyle(.secondary)
                                }
                            )
                    @unknown default:
                        Rectangle()
                            .fill(.secondary.opacity(0.2))
                            .overlay(Text("Unknown state").font(.caption).foregroundStyle(.secondary))
                    }
                }
            } else if viewModel.isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            } else {
                Rectangle()
                    .fill(.secondary.opacity(0.2))
                    .overlay(Text("No URL available").font(.caption).foregroundStyle(.secondary))
            }
        }
        .task {
            await viewModel.fetchPresignedURL()
        }
    }
}

// MARK: - MediaViewModel
@MainActor
class MediaViewModel: ObservableObject {
    @Published var presignedURL: URL?
    @Published var isLoading = true
    
    let mediaKey: String
    private let model: MediaModel
    
    init(mediaKey: String, model: MediaModel = MediaModel()) {
        self.mediaKey = mediaKey
        self.model = model
    }
    
    func fetchPresignedURL() async {
        do {
            print("📸 MediaViewModel: Fetching presigned URL for key: \(mediaKey)")
            let result = try await model.fetchPresignedReadURL(for: mediaKey)
            print("📸 MediaViewModel: Got presigned URL: \(result.url)")
            presignedURL = result.url
            isLoading = false
        } catch {
            print("📸 MediaViewModel: Error fetching presigned URL: \(error.localizedDescription)")
            isLoading = false
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let feed: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    func string(fromISO s: String) -> String {
        let iso = ISO8601DateFormatter()
        return string(from: iso.date(from: s) ?? Date())
    }
}
