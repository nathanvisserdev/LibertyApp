//
//  PostResponseDTO.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import Foundation

struct PostRequestResponseDTO: Codable {
    let id: String
    let content: String
    let createdAt: String
    let userId: String
}
