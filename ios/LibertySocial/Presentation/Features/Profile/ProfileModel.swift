//
//  ProfileModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

struct UserProfile: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let username: String
    let profilePhoto: String?
    let about: String?
    let gender: String?
    let connectionStatus: String?
    let requestType: String?
}
