// AuthView.swift
// Float

import SwiftUI

/// Auth gate — routes to onboarding, main app, or sign-in based on auth state
struct AuthView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isLoading && authService.session == nil {
                // Splash / loading while checking session
                ZStack {
                    FloatColors.background.ignoresSafeArea()
                    VStack(spacing: FloatSpacing.lg) {
                        Image(systemName: "wineglass.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(FloatColors.primary)
                        ProgressView().tint(FloatColors.primary)
                    }
                }
            } else if authService.isAuthenticated {
                if authService.needsOnboarding {
                    OnboardingView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else {
                    ContentView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            } else {
                SignInView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: authService.needsOnboarding)
    }
}
