//
//  SignupModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

struct AvailabilityRequest: Encodable {
    let email: String?
    let username: String?
}

struct AvailabilityResponse: Decodable {
    let available: Bool
}

struct SignupRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let username: String
    let password: String
    let dateOfBirth: String
    let gender: String
    let phoneNumber: String?
    let profilePhoto: String?
    let about: String?
    
    init(firstName: String, lastName: String, email: String, username: String, password: String, dateOfBirth: String, gender: String, phoneNumber: String? = nil, profilePhoto: String? = nil, about: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.password = password
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.phoneNumber = phoneNumber
        self.profilePhoto = profilePhoto
        self.about = about
    }
}

struct SignupResponse: Decodable { let id: String; let email: String }
