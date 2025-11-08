
import SwiftUI
import Combine

struct PostRowView: View {
    let post: PostItem
    let currentUserId: String?
    let showMenu: Bool
    let makeMediaVM: (String) -> MediaViewModel
    @Binding var thread: CommentThreadState
    let onToggleComments: () -> Void
    let onChangeInput: (String) -> Void
    let onSubmitComment: () -> Void

    init(post: PostItem,
         currentUserId: String?,
         showMenu: Bool,
         makeMediaVM: @escaping (String) -> MediaViewModel,
         thread: Binding<CommentThreadState>,
         onToggleComments: @escaping () -> Void,
         onChangeInput: @escaping (String) -> Void,
         onSubmitComment: @escaping () -> Void) {
        self.post = post
        self.currentUserId = currentUserId
        self.showMenu = showMenu
        self.makeMediaVM = makeMediaVM
        self._thread = thread
        self.onToggleComments = onToggleComments
        self.onChangeInput = onChangeInput
        self.onSubmitComment = onSubmitComment
    }

    private var isCurrentUsersPost: Bool {
        guard let currentUserId = currentUserId else { return false }
        return post.userId == currentUserId
    }

    private var authorDisplayName: String { "\(post.user.firstName) \(post.user.lastName)" }
    private var authorUsername: String { "@\(post.user.username)" }
    private var formattedDate: String { DateFormatters.string(fromISO: post.createdAt) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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

            if let mediaKey = post.media {
                MediaImageView(
                    viewModel: makeMediaVM(mediaKey),
                    orientation: post.orientation
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if let content = post.content {
                Text(content).font(.body)
            }

            HStack(spacing: 8) {
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Button {
                    onToggleComments()
                } label: {
                    Image(systemName: "message")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Image(systemName: "bell")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Image(systemName: "face.smiling")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Menu {
                    Button("True") {}
                    Button("False") {}
                    Button("Out of Context") {}
                } label: {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            if thread.isOpen {
                Divider()
                
                if thread.isLoading {
                    ProgressView()
                        .padding(.vertical, 8)
                }
                
                ForEach(thread.comments) { c in
                    CommentRowView(
                        comment: c,
                        isMine: c.user?.id == currentUserId,
                        formattedDate: DateFormatters.string(fromISO: c.createdAt)
                    )
                }
                
                HStack {
                    TextField("Add a comment...", text: Binding(
                        get: { thread.inputText },
                        set: { onChangeInput($0) }
                    ), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                    
                    Button {
                        onSubmitComment()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(thread.inputText.isEmpty ? .secondary : .blue)
                    }
                    .disabled(thread.inputText.isEmpty)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 4)
    }
}

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

@MainActor
class MediaViewModel: ObservableObject {
    @Published var presignedURL: URL?
    @Published var isLoading = true
    
    let mediaKey: String
    private let model: MediaModel
    
    init(mediaKey: String, model: MediaModel) {
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
