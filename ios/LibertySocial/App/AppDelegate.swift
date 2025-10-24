//
//  AppDelegate.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-23.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request push notification permissions
        Task {
            try? await PushNotificationManager.shared.requestAuthorization()
        }
        
        return true
    }
    
    // Called when APNs successfully registers the device
    func application(_ application: UIApplication, 
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task { @MainActor in
            PushNotificationManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
        }
    }
    
    // Called when APNs registration fails
    func application(_ application: UIApplication, 
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Task { @MainActor in
            PushNotificationManager.shared.didFailToRegisterForRemoteNotifications(error: error)
        }
    }
    
    // Called when a remote notification arrives while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Task { @MainActor in
            PushNotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo)
        }
        
        // Show banner, sound, and badge even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Called when user taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Task { @MainActor in
            PushNotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    // Handle background notifications
    func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Task { @MainActor in
            PushNotificationManager.shared.didReceiveRemoteNotification(userInfo: userInfo)
        }
        
        completionHandler(.newData)
    }
}
