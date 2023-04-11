//
//  TimeAgoCalculator.swift
//  Derkach02
//
//  Created by Kyrylo Derkach on 09.04.2023.
//

import Foundation

class TimeAgoCalculator {
    
    static func timeAgoSinceDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
        if let year = components.year, year >= 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: date)
        }
        if let month = components.month, month >= 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            return formatter.string(from: date)
        }
        if let weekOfYear = components.weekOfYear, weekOfYear >= 1 {
            return "\(weekOfYear)w"
        }
        if let day = components.day, day >= 1 {
            return "\(day)d"
        }
        if let hour = components.hour, hour >= 1 {
            return "\(hour)h"
        }
        if let minute = components.minute, minute >= 1 {
            return "\(minute)m"
        }
        if let second = components.second, second >= 3 {
            return "\(second)s"
        }
        return "just now"
    }
    
}
