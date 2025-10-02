//
//  Item.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-02.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
