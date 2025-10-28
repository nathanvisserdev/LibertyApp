//
//  CreatePostVM.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import Foundation
import Combine

@MainActor
final class CreatePostViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String?
    @Published var presignedUploadData: PresignedUploadResponse?
    let maxCharacters = 1000
    private let useCase = CreatePostUseCase()

    var remainingCharacters: Int {
        maxCharacters - text.count
    }

    func requestPresignedUpload() async {
        errorMessage = nil
        do {
            presignedUploadData = try await PostsAPI.getPresignedUploadURL(contentType: "image/jpeg")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func submit() async {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        do {
            try await useCase.execute(text: text)
            text = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isSubmitting = false
    }
}

struct CreatePostUseCase {
    let maxCharacters = 1000
    func execute(text: String) async throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ValidationError.empty
        }
        guard trimmed.count <= maxCharacters else {
            throw ValidationError.tooLong
        }
        _ = try await PostsAPI.createPost(content: trimmed)
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


