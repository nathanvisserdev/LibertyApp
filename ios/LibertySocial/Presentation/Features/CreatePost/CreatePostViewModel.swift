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
    private let feedService: FeedSession
    
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
    @Published var userIsPrivate: Bool = false
    @Published var userSubnets: [Subnet] = []
    @Published var isLoadingUserData: Bool = false
    
    // MARK: - Private State
    private var presignedUploadData: PresignedUploadResponse?
    
    // MARK: - Constants
    let maxCharacters = 1000
    
    // MARK: - Init
    init(model: CreatePostModel = CreatePostModel(), feedService: FeedSession = FeedService.shared) {
        self.model = model
        self.feedService = feedService
    }
    
    // MARK: - Load User Data
    func loadCurrentUserData() async {
        isLoadingUserData = true
        do {
            // Fetch user's private status and subnets concurrently
            async let isPrivate = model.getCurrentUserIsPrivate()
            async let subnets = model.getUserSubnets()
            
            userIsPrivate = try await isPrivate
            userSubnets = try await subnets
            
            // Set default audience based on user's privacy setting
            if selectedAudience == "Select Audience" {
                selectedAudience = defaultAudience
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
            errorMessage = "Failed to load user data"
        }
        isLoadingUserData = false
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
    
    // MARK: - Audience Logic
    
    /// Default audience based on user's privacy setting
    var defaultAudience: String {
        userIsPrivate ? "Connections" : "Public"
    }
    
    /// Available audience options for the dropdown
    var availableAudiences: [String] {
        var audiences: [String] = []
        
        if userIsPrivate {
            // Private users: Connections (default), Acquaintances, Strangers, + Subnets
            audiences.append("Connections")
            audiences.append("Acquaintances")
            audiences.append("Strangers")
        } else {
            // Public users: Public (default) + Subnets
            audiences.append("Public")
        }
        
        // Add user's subnets
        for subnet in userSubnets {
            audiences.append(subnet.name)
        }
        
        return audiences
    }
    
    /// Converts the UI-friendly audience selection to the backend visibility format
    private var visibilityForSelectedAudience: String {
        switch selectedAudience {
        case "Public":
            return "PUBLIC"
        case "Connections":
            return "CONNECTIONS"
        case "Acquaintances":
            return "ACQUAINTANCES"
        case "Strangers":
            return "STRANGERS"
        default:
            // It's a subnet name - check if it exists in userSubnets
            if userSubnets.contains(where: { $0.name == selectedAudience }) {
                return "SUBNET"
            }
            // Fallback to PUBLIC if somehow an invalid audience is selected
            return "PUBLIC"
        }
    }
    
    /// Returns the subnet ID if a subnet is selected, nil otherwise
    private var subnetIdForSelectedAudience: String? {
        // Check if selected audience is a subnet name
        if let subnet = userSubnets.first(where: { $0.name == selectedAudience }) {
            return subnet.id
        }
        return nil
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
                imageHeight: imageHeight,
                visibility: visibilityForSelectedAudience,
                subnetId: subnetIdForSelectedAudience
            )
            
            // Invalidate feed cache to trigger refresh
            feedService.invalidateCache()
            
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

