
import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
final class CreatePostViewModel: ObservableObject {
    
    private let model: CreatePostModel
    private let feedService: FeedSession
    
    @Published var text: String = ""
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var selectedAudience: String = "Select Audience"
    
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
    
    private var presignedUploadData: PresignedUploadResponse?
    
    let maxCharacters = 1000
    
    init(model: CreatePostModel, feedService: FeedSession) {
        self.model = model
        self.feedService = feedService
    }
    
    func loadCurrentUserData() async {
        isLoadingUserData = true
        do {
            async let isPrivate = model.getCurrentUserIsPrivate()
            async let subnets = model.getUserSubnets()
            
            userIsPrivate = try await isPrivate
            userSubnets = try await subnets
            
            if selectedAudience == "Select Audience" {
                selectedAudience = defaultAudience
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
            errorMessage = "Failed to load user data"
        }
        isLoadingUserData = false
    }
    
    var remainingCharacters: Int {
        maxCharacters - text.count
    }
    
    var canSubmit: Bool {
        let hasContent = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasMedia = localMediaURL != nil
        return (hasContent || hasMedia) && remainingCharacters >= 0 && !isSubmitting
    }
    
    
    var defaultAudience: String {
        userIsPrivate ? "Connections" : "Public"
    }
    
    var availableAudiences: [String] {
        var audiences: [String] = []
        
        if userIsPrivate {
            audiences.append("Connections")
            audiences.append("Acquaintances")
            audiences.append("Strangers")
        } else {
            audiences.append("Public")
        }
        
        for subnet in userSubnets {
            audiences.append(subnet.name)
        }
        
        return audiences
    }
    
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
            if userSubnets.contains(where: { $0.name == selectedAudience }) {
                return "SUBNET"
            }
            return "PUBLIC"
        }
    }
    
    private var subnetIdForSelectedAudience: String? {
        if let subnet = userSubnets.first(where: { $0.name == selectedAudience }) {
            return subnet.id
        }
        return nil
    }
    
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
                if let uiImage = UIImage(data: data) {
                    imageWidth = uiImage.size.width
                    imageHeight = uiImage.size.height
                }
                
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("jpg")
                
                try data.write(to: tempURL)
                localMediaURL = tempURL
                
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
            
            _ = try await model.createPost(
                content: trimmed.isEmpty ? nil : trimmed,
                media: mediaKey,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                visibility: visibilityForSelectedAudience,
                subnetId: subnetIdForSelectedAudience
            )
            
            feedService.invalidateCache()
            
            clearForm()
            
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

