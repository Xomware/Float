// Date+Relative.swift
// Float

import Foundation

extension Date {
    var relativeToNow: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    var timeRemainingShort: String {
        let interval = timeIntervalSinceNow
        guard interval > 0 else { return "Expired" }
        
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if days > 0 {
            return "\(days)d \(hours)h left"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m left"
        } else if minutes > 0 {
            return "\(minutes)m left"
        } else {
            return "Expires soon"
        }
    }
    
    var isExpiringSoon: Bool { timeIntervalSinceNow < 3600 && timeIntervalSinceNow > 0 }
    var isExpired: Bool { timeIntervalSinceNow <= 0 }
}
