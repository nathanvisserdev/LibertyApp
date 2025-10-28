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
    @Published var text: String = ""
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    @Published var presignedUploadData: PresignedUploadResponse?
    @Published var selectedPhoto: PhotosPickerItem?
    let maxCharacters = 1000

    var remainingCharacters: Int {
        maxCharacters - text.count
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
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
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

