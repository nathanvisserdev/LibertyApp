//
//  NotificationsService.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-11-04.
//

import Foundation

@MainActor
protocol NotificationManaging: AnyObject {
    var deviceToken: String? { get }
    func requestAuthorization() async throws
    func didRegisterForRemoteNotifications(deviceToken: Data)
    func didFailToRegisterForRemoteNotifications(error: Error)
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any])
    func unregisterDevice() async
}

