
import Foundation
import UserNotifications
import UIKit
import Combine

@MainActor
final class NotificationManager: NSObject, ObservableObject, NotificationManaging {

    @Published private(set) var deviceToken: String?

    private let tokenProvider: TokenProviding

    init(tokenProvider: TokenProviding) {
        self.tokenProvider = tokenProvider
        super.init()
    }

    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        if granted {
            await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
        }
    }

    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        Task { await registerDeviceWithBackend(token: tokenString) }
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("APNs registration failed: \(error)")
    }

    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? [String: Any],
           let badge = aps["badge"] as? Int {
            UIApplication.shared.applicationIconBadgeNumber = badge
        }
        if let type = userInfo["type"] as? String, type == "connection_request" {
            UserDefaults.standard.set(true, forKey: "newConnectionRequest")
            NotificationCenter.default.post(name: .connectionRequestReceived, object: nil)
        }
    }

    func unregisterDevice() async {
        guard let token = deviceToken else { return }
        do {
            let authToken = try tokenProvider.getAuthToken()
            let body = ["token": token]
            let data = try JSONSerialization.data(withJSONObject: body)
            var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/devices/unregister"))
            req.httpMethod = "DELETE"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            req.httpBody = data
            let (_, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                self.deviceToken = nil
            }
        } catch {
            print("Unregister error: \(error)")
        }
    }

    private func registerDeviceWithBackend(token: String) async {
        do {
            let authToken = try tokenProvider.getAuthToken()
            let body = ["token": token, "platform": "ios"]
            let data = try JSONSerialization.data(withJSONObject: body)
            var req = URLRequest(url: AuthManager.baseURL.appendingPathComponent("/devices/register"))
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            req.httpBody = data
            _ = try await URLSession.shared.data(for: req)
        } catch {
            print("Register error: \(error)")
        }
    }
}

extension Notification.Name {
    static let connectionRequestReceived = Notification.Name("connectionRequestReceived")
}
