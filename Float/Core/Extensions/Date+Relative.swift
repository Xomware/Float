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
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 0 { return "\(hours)h \(minutes)m left" }
        return "\(minutes)m left"
    }
    
    var isExpiringSoon: Bool { timeIntervalSinceNow < 3600 && timeIntervalSinceNow > 0 }
    var isExpired: Bool { timeIntervalSinceNow <= 0 }
}
