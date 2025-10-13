import Foundation

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
