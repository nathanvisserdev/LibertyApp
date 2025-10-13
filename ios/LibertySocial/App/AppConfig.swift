//
//  AppConfig.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-12.
//

import Foundation

enum AppConfig {
    // Simulator: 127.0.0.1. On a real device, use your Mac’s LAN IP (e.g., http://192.168.0.10:3000)
    static let base = URL(string: "http://127.0.0.1:3000")!
}
