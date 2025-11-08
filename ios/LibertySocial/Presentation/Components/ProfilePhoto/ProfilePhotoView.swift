
import SwiftUI

struct ProfilePhotoView: View {
    @StateObject private var viewModel: ProfilePhotoViewModel
    
    init(photoKey: String) {
        _viewModel = StateObject(wrappedValue: ProfilePhotoViewModel(photoKey: photoKey))
    }
    
    var body: some View {
        Group {
            if let url = viewModel.presignedURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    case .failure(let error):
                        let _ = print("📸 ProfilePhotoView: Image load failed: \(error.localizedDescription)")
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else if viewModel.isLoading {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(ProgressView())
            } else {
                placeholderView
            }
        }
        .task {
            await viewModel.fetchPresignedURL()
        }
        .onAppear {
            Task {
                await viewModel.refreshIfExpired()
            }
        }
    }
    
    private var placeholderView: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 120, height: 120)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
            )
    }
}
