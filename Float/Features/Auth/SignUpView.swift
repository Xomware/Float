import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordMismatch = false
    
    var body: some View {
        ZStack {
            FloatColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: FloatSpacing.lg) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 56))
                        .foregroundStyle(FloatColors.primary)
                        .padding(.top, FloatSpacing.xl)
                    
                    Text("Create Account")
                        .font(FloatFont.title())
                        .foregroundStyle(.white)
                    
                    VStack(spacing: FloatSpacing.sm) {
                        FloatTextField("Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                        FloatTextField("Password (6+ characters)", text: $password, icon: "lock", isSecure: true)
                        FloatTextField("Confirm Password", text: $confirmPassword, icon: "lock.shield", isSecure: true)
                        
                        if passwordMismatch {
                            Text("Passwords don't match")
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.error)
                        }
                        
                        if let error = authService.authError {
                            Text(error).font(FloatFont.caption()).foregroundStyle(FloatColors.error).multilineTextAlignment(.center)
                        }
                        
                        FloatButton("Create Account", isLoading: authService.isLoading) {
                            guard password == confirmPassword else { passwordMismatch = true; return }
                            passwordMismatch = false
                            Task { await authService.signUpWithEmail(email: email, password: password) }
                        }
                        
                        Text("By creating an account you agree to our Terms of Service and Privacy Policy.")
                            .font(FloatFont.caption2())
                            .foregroundStyle(FloatColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, FloatSpacing.lg)
                }
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}
