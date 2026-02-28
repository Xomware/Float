import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                ContentView()
            } else {
                SignInView()
            }
        }
    }
}
