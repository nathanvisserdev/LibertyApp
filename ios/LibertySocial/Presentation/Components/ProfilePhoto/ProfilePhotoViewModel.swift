//
//  ProfilePhotoViewModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

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
    
    init(photoKey: String) {
        self.photoKey = photoKey
    }
    
    func fetchPresignedURL() async {
        do {
            let result = try await ProfilePhotoModel.fetchPresignedURL(for: photoKey)
            
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
