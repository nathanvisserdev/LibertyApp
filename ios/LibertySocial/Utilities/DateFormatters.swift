//
//  DateFormatters.swift
//  LibertySocial
//
//  Created by Nathan Visser on 2025-10-28.
//

import Foundation

enum DateFormatters {
    static let relativeShort: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()
    
    static let feed: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()
    
    static func string(fromISO isoString: String) -> String {
        let iso = ISO8601DateFormatter()
        guard let date = iso.date(from: isoString) else {
            return isoString
        }
        return feed.string(from: date)
    }
}
