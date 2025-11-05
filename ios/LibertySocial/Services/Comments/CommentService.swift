//
//  CommentService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-03.
//

import Foundation

struct CommentItem: Codable, Identifiable {
    let commentId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let userId: String
    let postId: String
    let parentId: String?
    let user: UserSummary?
    
    var id: String { commentId }
    
    struct UserSummary: Codable {
        let id: String
        let username: String
        let firstName: String
        let lastName: String
        let profilePhoto: String
    }
}

protocol CommentService {
    func fetch(postId: String, cursor: String?) async throws -> ([CommentItem], String?)
    func create(postId: String, content: String) async throws -> CommentItem
    func delete(commentId: String) async throws
}

final class DefaultCommentService: CommentService {
    private let auth: AuthManaging

    init(auth: AuthManaging) {
        self.auth = auth
    }

    func fetch(postId: String, cursor: String?) async throws -> ([CommentItem], String?) {
        // TODO: implement network request
        return ([], nil)
    }

    func create(postId: String, content: String) async throws -> CommentItem {
        // TODO: implement network request
        return CommentItem(
            commentId: UUID().uuidString,
            content: content,
            createdAt: "",
            updatedAt: "",
            userId: "",
            postId: postId,
            parentId: nil,
            user: nil
        )
    }

    func delete(commentId: String) async throws {
        // TODO: implement deletion call
    }
}
