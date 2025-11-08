
import Foundation
import SwiftUI
import Combine

@MainActor
class ProfilePhotoViewModel: ObservableObject {
    @Published var presignedURL: URL?
    @Published var expiresAt: Date?
    @Published var isLoading = true
    @Published var loadError: String?
    
    let photoKey: String
    private let model: ProfilePhotoModel
    
    init(photoKey: String, model: ProfilePhotoModel = ProfilePhotoModel()) {
        self.photoKey = photoKey
        self.model = model
    }
    
    func fetchPresignedURL() async {
        do {
            let result = try await model.fetchPresignedURL(for: photoKey)
            
            presignedURL = result.url
            expiresAt = result.expiresAt
            isLoading = false
        } catch {
            print("📸 ProfilePhotoViewModel: Error fetching presigned URL: \(error.localizedDescription)")
            loadError = error.localizedDescription
            isLoading = false
        }
    }
    
    func refreshIfExpired() async {
        if let expiresAt = expiresAt, Date() > expiresAt {
            await fetchPresignedURL()
        }
    }
}
