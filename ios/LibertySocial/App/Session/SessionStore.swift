//
//  SessionStore.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-07.
//

import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var isAuthenticated = false

    init() { refresh() }

    func refresh() {
        if let token = KeychainHelper.read(), !isExpired(token) {
            isAuthenticated = true
        } else {
            KeychainHelper.delete()
            isAuthenticated = false
        }
    }

    func logout() {
        KeychainHelper.delete()
        isAuthenticated = false
    }
}

// Minimal JWT exp check (no signature verification)
private func jwtExpiry(_ token: String) -> Date? {
    let parts = token.split(separator: ".")
    guard parts.count >= 2 else { return nil }

    func decodeBase64URL(_ s: Substring) -> Data? {
        var str = String(s).replacingOccurrences(of: "-", with: "+")
                            .replacingOccurrences(of: "_", with: "/")
        let pad = 4 - (str.count % 4)
        if pad < 4 { str.append(String(repeating: "=", count: pad)) }
        return Data(base64Encoded: str)
    }

    guard let payload = decodeBase64URL(parts[1]),
          let obj = try? JSONSerialization.jsonObject(with: payload) as? [String: Any],
          let exp = obj["exp"] as? TimeInterval
    else { return nil }

    return Date(timeIntervalSince1970: exp)
}

private func isExpired(_ token: String, skewSeconds: TimeInterval = 30) -> Bool {
    guard let exp = jwtExpiry(token) else { return false }
    return Date().addingTimeInterval(skewSeconds) >= exp
}

