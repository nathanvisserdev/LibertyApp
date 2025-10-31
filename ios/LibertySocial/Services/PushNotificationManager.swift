//
//  PushNotificationManager.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import Foundation
import UserNotifications
import UIKit
import Combine

@MainActor
class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()
    
    @Published var deviceToken: String?
    
    // MARK: - Dependencies
    private let authSession: AuthSession
    
    // MARK: - Init
    init(authSession: AuthSession = AuthService.shared) {
        self.authSession = authSession
        super.init()
    }
    
    /// Request notification permissions from the user
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        
        if granted {
            print("Push notification permission granted")
            // Register for remote notifications on the main thread
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            print("Push notification permission denied")
        }
    }
    
    /// Handle successful device token registration
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        // Convert device token to hex string
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        print("Device token: \(tokenString)")
        
        // Register token with backend
        Task {
            await registerDeviceWithBackend(token: tokenString)
        }
    }
    
    /// Handle device token registration failure
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    /// Register device token with backend server
    private func registerDeviceWithBackend(token: String) async {
        do {
            let authToken = try authSession.getAuthToken()
            
            let body = ["token": token, "platform": "ios"]
            let data = try JSONSerialization.data(withJSONObject: body)
            
            var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/devices/register"))
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            req.httpBody = data
            
            let (_, response) = try await URLSession.shared.data(for: req)
            
            if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                print("Device registered with backend successfully")
            } else {
                print("Failed to register device with backend")
            }
        } catch {
            print("Error registering device with backend: \(error)")
        }
    }
    
    /// Unregister device token from backend (call on logout)
    func unregisterDevice() async {
        guard let token = deviceToken else {
            return
        }
        
        do {
            let authToken = try authSession.getAuthToken()
            
            let body = ["token": token]
            let data = try JSONSerialization.data(withJSONObject: body)
            
            var req = URLRequest(url: AuthService.baseURL.appendingPathComponent("/devices/unregister"))
            req.httpMethod = "DELETE"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            req.httpBody = data
            
            let (_, response) = try await URLSession.shared.data(for: req)
            
            if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                print("Device unregistered from backend successfully")
                deviceToken = nil
            }
        } catch {
            print("Error unregistering device: \(error)")
        }
    }
    
    /// Handle incoming remote notification
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        print("Received remote notification: \(userInfo)")
        
        // Check if this is a connection request notification
        if let type = userInfo["type"] as? String, type == "connection_request" {
            // Set the badge to show new connection request
            UserDefaults.standard.set(true, forKey: "newConnectionRequest")
            
            // Update app badge count if provided
            if let aps = userInfo["aps"] as? [String: Any],
               let badge = aps["badge"] as? Int {
                UIApplication.shared.applicationIconBadgeNumber = badge
            }
            
            // Post notification for app to update UI
            NotificationCenter.default.post(name: .connectionRequestReceived, object: nil)
        }
    }
}

// Notification name for connection request updates
extension Notification.Name {
    static let connectionRequestReceived = Notification.Name("connectionRequestReceived")
}
