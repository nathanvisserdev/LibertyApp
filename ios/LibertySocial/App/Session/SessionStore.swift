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
            // Check for pending connection requests when session is active
            Task {
                await checkPendingRequests()
            }
        } else {
            KeychainHelper.delete()
            isAuthenticated = false
        }
    }
    
    /// Check if there are pending connection requests and update badge
    private func checkPendingRequests() async {
        do {
            let response = try await fetchPendingCount()
            print("📬 Pending request count: \(response.pendingRequestCount)")
            // Update badge if there are pending requests
            let hasPending = response.pendingRequestCount > 0
            UserDefaults.standard.set(hasPending, forKey: "newConnectionRequest")
            print("📬 Badge set to: \(hasPending)")
        } catch {
            print("❌ Failed to fetch pending request count: \(error)")
        }
    }
    
    /// Fetch pending request count from backend
    private func fetchPendingCount() async throws -> PendingCountResponse {
        guard let token = KeychainHelper.read() else {
            throw NSError(domain: "SessionStore", code: 401, userInfo: [NSLocalizedDescriptionKey: "No auth token"])
        }
        
        var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/devices/pending-count"))
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SessionStore", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch pending count"])
        }
        
        return try JSONDecoder().decode(PendingCountResponse.self, from: data)
    }

    func logout() {
        // Unregister device token from backend
        Task {
            await PushNotificationManager.shared.unregisterDevice()
        }
        
        // Clear auth token and badge state
        KeychainHelper.delete()
        UserDefaults.standard.set(false, forKey: "newConnectionRequest")
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

struct PendingCountResponse: Decodable {
    let pendingRequestCount: Int
}
