import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let firstName: String?
    let lastName: String?
    let avatarURL: URL?
    let dateOfBirth: String?
    let gender: Bool?
}
