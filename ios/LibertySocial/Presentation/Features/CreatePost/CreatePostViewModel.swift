//
//  CreatePostVM.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
final class CreatePostViewModel: ObservableObject {
    struct Draft {
        var text: String = ""
        var localMedia: [URL] = []   // temp file URLs from picker
    }
    
    @Published var draft = Draft()
    @Published var text: String = ""
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    @Published var presignedUploadData: PresignedUploadResponse?
    @Published var selectedPhoto: PhotosPickerItem?
    let maxCharacters = 1000

    var remainingCharacters: Int {
        maxCharacters - draft.text.count
    }
    
    func loadSelectedPhoto() async {
        guard let selectedPhoto = selectedPhoto else { return }
        
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self) {
                // Save to temporary file
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")
                
                try data.write(to: tempURL)
                draft.localMedia = [tempURL]
                
                // Upload the photo to R2 using the presigned URL
                if let uploadData = presignedUploadData {
                    try await uploadPhoto(data: data, uploadData: uploadData)
                }
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
        }
    }
    
    private func uploadPhoto(data: Data, uploadData: PresignedUploadResponse) async throws {
        guard let url = URL(string: uploadData.url) else {
            throw NSError(domain: "CreatePostViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid upload URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = uploadData.method
        
        // Set headers from presigned response
        for (key, value) in uploadData.headersOrFields {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "CreatePostViewModel", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to upload photo"])
        }
        
        print("📸 CreatePostViewModel: Successfully uploaded photo to R2")
    }

    func requestPresignedUpload() async -> Bool {
        errorMessage = nil
        do {
            presignedUploadData = try await PostsAPI.getPresignedUploadURL(contentType: "image/jpeg")
            return true
        } catch {
            errorMessage = "Failed to prepare upload: \(error.localizedDescription)"
            return false
        }
    }

    func submit() async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        
        do {
            let trimmed = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let mediaKey = presignedUploadData?.key
            
            // Validate that we have either content or media
            guard !trimmed.isEmpty || mediaKey != nil else {
                throw ValidationError.empty
            }
            
            // Validate content length if provided
            if !trimmed.isEmpty && trimmed.count > maxCharacters {
                throw ValidationError.tooLong
            }
            
            // Create the post with content and/or media
            _ = try await PostsAPI.createPost(
                content: trimmed.isEmpty ? nil : trimmed,
                media: mediaKey
            )
            
            // Clear the form on success
            draft = Draft()
            text = ""
            presignedUploadData = nil
            selectedPhoto = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
    
    enum ValidationError: LocalizedError {
        case empty
        case tooLong
        
        var errorDescription: String? {
            switch self {
            case .empty: return "Post cannot be empty."
            case .tooLong: return "Post must be 1000 characters or less."
            }
        }
    }
}

