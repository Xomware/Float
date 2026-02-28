import SwiftUI
import Supabase

@main
struct FloatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(authService)
                .preferredColorScheme(.dark)
        }
    }
}
