//
//  FeedView.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-09.
//

import SwiftUI
import Combine

struct FeedView: View {
    @StateObject private var vm: FeedViewModel
    @EnvironmentObject private var session: SessionStore
    
    init(viewModel: FeedViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.items.isEmpty {
                    ProgressView("Loading…")
                } else if let err = vm.error {
                    VStack(spacing: 12) {
                        Text(err).foregroundStyle(.red)
                        Button("Retry") { Task { await vm.load() } }
                    }
                } else {
                    List {
                        if !vm.mine.isEmpty          { Section("Your posts") { rows(vm.mine) } }
                        if !vm.acquaintances.isEmpty { Section("Acquaintances") { rows(vm.acquaintances) } }
                        if !vm.strangers.isEmpty     { Section("Strangers") { rows(vm.strangers) } }
                        if !vm.following.isEmpty     { Section("Following") { rows(vm.following) } }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable { await vm.refresh() }
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log out") {
                        AuthService.shared.deleteToken()
                        Task {
                            await session.refresh()
                        }
                    }
                }
            }
        }
        .task { await vm.load() }
        .safeAreaInset(edge: .bottom) {
            TabBarCoordinator().start()
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder private func rows(_ items: [FeedItem]) -> some View {
        ForEach(items, id: \.id) { item in
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(item.user.firstName) \(item.user.lastName) (@\(item.user.username))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if vm.isUsersPost(item) {
                        Image(systemName: "ellipsis")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Display media if available
                if let mediaKey = item.media {
                    MediaImageView(mediaKey: mediaKey, orientation: item.orientation)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Display content if available
                if let content = item.content {
                    Text(content).font(.body)
                }
                
                Text(DateFormatter.feed.string(fromISO: item.createdAt))
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

struct MediaImageView: View {
    @StateObject private var viewModel: MediaViewModel
    let orientation: String?
    
    init(mediaKey: String, orientation: String?) {
        _viewModel = StateObject(wrappedValue: MediaViewModel(mediaKey: mediaKey))
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

private extension DateFormatter {
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
