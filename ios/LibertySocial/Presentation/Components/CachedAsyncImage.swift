//
//  CachedAsyncImage.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

// Actor to manage image cache
private actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [String: UIImage] = [:]
    
    func get(key: String) -> UIImage? {
        return cache[key]
    }
    
    func set(key: String, image: UIImage) {
        cache[key] = image
    }
}

struct CachedAsyncImage: View {
    let url: URL
    let cacheKey: String // Use photo key as cache key, not the presigned URL
    let width: CGFloat
    let height: CGFloat
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
            } else if isLoading {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: width, height: height)
                    .overlay(ProgressView())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: width, height: height)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: width * 0.4))
                            .foregroundColor(.gray)
                    )
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        // Check cache first
        if let cachedImage = await ImageCache.shared.get(key: cacheKey) {
            print("📸 CachedAsyncImage: Using cached image for \(cacheKey)")
            await MainActor.run {
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }
        
        // Download image
        do {
            print("📸 CachedAsyncImage: Downloading image for \(cacheKey)")
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let uiImage = UIImage(data: data) {
                // Cache the image
                await ImageCache.shared.set(key: cacheKey, image: uiImage)
                
                await MainActor.run {
                    self.image = uiImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        } catch {
            print("📸 CachedAsyncImage: Failed to load image: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
