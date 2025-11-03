//
//  ReactionService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-03.
//

import Foundation
import Combine

enum ReactionType: String, Codable {
    case bell = "BELL"
    case trueReaction = "TRUE"
    case falseReaction = "FALSE"
    case outOfContext = "OUT_OF_CONTEXT"
    case emoji = "EMOJI"
}

struct ReactionSummary: Codable {
    let postId: String
    let bellCount: Int
    let trueCount: Int
    let falseCount: Int
    let outOfContextCount: Int
    let emojiReactions: [EmojiCount]
    let userReactions: [UserReaction]
    
    struct EmojiCount: Codable {
        let emoji: String
        let count: Int
    }
    
    struct UserReaction: Codable {
        let type: ReactionType
        let emoji: String?
    }
}

protocol ReactionService {
    func summary(for postId: String) -> AnyPublisher<ReactionSummary, Never>
    func toggle(postId: String, type: ReactionType, emoji: String?) async throws
}
