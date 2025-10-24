//
//  ProfilePhotoView.swift
//  LibertySocial
//
//  Created by AI Assistant on 2025-10-24.
//

import SwiftUI

struct ProfilePhotoView: View {
    let photoKey: String
    @State private var presignedURL: URL?
    @State private var expiresAt: Date?
    @State private var isLoading = true
    @State private var loadError: String?
    
    var body: some View {
        Group {
            if let url = presignedURL {
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
            } else if isLoading {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(ProgressView())
            } else {
                placeholderView
            }
        }
        .task {
            await fetchPresignedURL()
        }
        .onAppear {
            // Check if URL has expired and refresh if needed
            if let expiresAt = expiresAt, Date() > expiresAt {
                Task {
                    await fetchPresignedURL()
                }
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
    
    private func fetchPresignedURL() async {
        guard let token = KeychainHelper.read() else {
            print("📸 ProfilePhotoView: No auth token")
            isLoading = false
            return
        }
        
        do {
            let body = ["key": photoKey]
            let data = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: AuthService.baseURL.appendingPathComponent("/media/presign-read"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = data
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                throw NSError(domain: "ProfilePhotoView", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to get presigned URL"])
            }
            
            let presignResponse = try JSONDecoder().decode(PresignReadResponse.self, from: responseData)
            
            print("📸 ProfilePhotoView: Got presigned URL, expires at: \(Date(timeIntervalSince1970: Double(presignResponse.expiresAt) / 1000))")
            
            await MainActor.run {
                self.presignedURL = URL(string: presignResponse.url)
                self.expiresAt = Date(timeIntervalSince1970: Double(presignResponse.expiresAt) / 1000)
                self.isLoading = false
            }
        } catch {
            print("📸 ProfilePhotoView: Error fetching presigned URL: \(error.localizedDescription)")
            await MainActor.run {
                self.loadError = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

struct PresignReadResponse: Decodable {
    let url: String
    let expiresAt: Int64
}
