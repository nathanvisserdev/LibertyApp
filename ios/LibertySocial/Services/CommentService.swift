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
    
    var id: String { commentId }
}

protocol CommentService {
    func fetch(postId: String, cursor: String?) async throws -> ([CommentItem], String?)
    func create(postId: String, content: String) async throws -> CommentItem
    func delete(commentId: String) async throws
}
