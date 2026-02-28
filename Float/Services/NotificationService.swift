import UserNotifications
import SwiftUI

@MainActor
class NotificationService: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            Logger.auth.info("Notification permission granted: \(granted)")
            await checkStatus()
        } catch {
            Logger.auth.error("Notification permission error: \(error)")
        }
    }
    
    func checkStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    func scheduleExpiryAlert(dealTitle: String, expiresAt: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Deal Expiring Soon! ⏰"
        content.body = "\(dealTitle) expires in 30 minutes"
        content.sound = .default
        
        let triggerDate = expiresAt.addingTimeInterval(-1800)
        guard triggerDate > Date() else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "deal-expiry-\(UUID())", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            Logger.auth.error("Failed to schedule notification: \(error)")
        }
    }
}
