import Foundation

struct Post: Codable, Identifiable {
    let id: String
    let author: User
    let content: String
    let createdAt: Date
    let updatedAt: Date?
    let likes: Int
    let commentsCount: Int
}
