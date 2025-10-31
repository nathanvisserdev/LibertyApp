//
//  CreatePostViewModel.swift
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
    
    // MARK: - Dependencies
    private let model: CreatePostModel
    
    // MARK: - Published (Input State)
    @Published var text: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var selectedAudience: String = "Select Audience"
    
    // MARK: - Published (UI State)
    @Published var localMediaURL: URL?
    @Published var imageWidth: CGFloat?
    @Published var imageHeight: CGFloat?
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    @Published var showPhotoPicker: Bool = false
    @Published var showAudiencePicker: Bool = false
    @Published var shouldDismiss: Bool = false
    
    // MARK: - Private State
    private var presignedUploadData: PresignedUploadResponse?
    
    // MARK: - Constants
    let maxCharacters = 1000
    
    // MARK: - Init
    init(model: CreatePostModel = CreatePostModel()) {
        self.model = model
    }
    
    // MARK: - Computed
    var remainingCharacters: Int {
        maxCharacters - text.count
    }
    
    var canSubmit: Bool {
        let hasContent = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasMedia = localMediaURL != nil
        return (hasContent || hasMedia) && remainingCharacters >= 0 && !isSubmitting
    }
    
    // MARK: - Intents (User Actions)
    func requestPresignedUpload() async {
        errorMessage = nil
        do {
            presignedUploadData = try await model.requestPresignedUpload()
            showPhotoPicker = true
        } catch {
            errorMessage = "Failed to prepare upload: \(error.localizedDescription)"
        }
    }
    
    func loadSelectedPhoto() async {
        guard let selectedPhoto = selectedPhoto else { return }
        
        do {
            if let data = try await selectedPhoto.loadTransferable(type: Data.self) {
                // Get image dimensions
                if let uiImage = UIImage(data: data) {
                    imageWidth = uiImage.size.width
                    imageHeight = uiImage.size.height
                }
                
                // Save to temporary file for preview
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")
                
                try data.write(to: tempURL)
                localMediaURL = tempURL
                
                // Upload the photo to R2 using the presigned URL
                if let uploadData = presignedUploadData {
                    try await model.uploadPhoto(data: data, uploadData: uploadData)
                }
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
        }
    }
    
    func submit() async {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil
        
        do {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let mediaKey = presignedUploadData?.key
            
            // Create the post with content and/or media
            _ = try await model.createPost(
                content: trimmed.isEmpty ? nil : trimmed,
                media: mediaKey,
                imageWidth: imageWidth,
                imageHeight: imageHeight
            )
            
            // Clear form on success
            clearForm()
            
            // Signal to dismiss the view
            shouldDismiss = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
    }
    
    func tapAudiencePicker() {
        showAudiencePicker = true
    }
    
    func selectAudience(_ audience: String) {
        selectedAudience = audience
        showAudiencePicker = false
    }
    
    // MARK: - Private Helpers
    private func clearForm() {
        text = ""
        localMediaURL = nil
        imageWidth = nil
        imageHeight = nil
        presignedUploadData = nil
        selectedPhoto = nil
        selectedAudience = "Select Audience"
    }
}

