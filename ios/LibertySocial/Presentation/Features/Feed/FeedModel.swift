//
//  FeedModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct FeedItem: Decodable {
    let id: String
    let userId: String
    let content: String
    let createdAt: String
    let user: UserSummary
    let relation: String
    struct UserSummary: Decodable { let id: String; let email: String }
}
