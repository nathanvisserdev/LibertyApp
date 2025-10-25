//
//  ErrorModel.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-25.
//

import Foundation

enum APIError: Error {
    case badURL
    case server(String)
    case unauthorized
    case decoding
    case unknown(Error?)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .server(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .decoding:
            return "Failed to decode response"
        case .unknown(let error):
            return error?.localizedDescription ?? "Unknown error"
        }
    }
}
