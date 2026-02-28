import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var showEmailFields = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                FloatColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero
                        VStack(spacing: FloatSpacing.md) {
                            Image(systemName: "wineglass.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(FloatColors.primary)
                                .padding(.top, 60)
                            
                            Text("Float")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Real-time deals at bars & restaurants near you")
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, FloatSpacing.xl)
                        }
                        .padding(.bottom, 48)
                        
                        // Auth buttons
                        VStack(spacing: FloatSpacing.md) {
                            // Sign in with Apple
                            SignInWithAppleButton(.signIn, onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            }, onCompletion: { _ in
                                Task { await authService.signInWithApple() }
                            })
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 52)
                            .cornerRadius(FloatSpacing.buttonRadius)
                            
                            // Sign in with Google
                            Button {
                                Task { await authService.signInWithGoogle() }
                            } label: {
                                HStack(spacing: FloatSpacing.sm) {
                                    Text("G")
                                        .font(.system(size: 18, weight: .bold, design: .serif))
                                        .foregroundStyle(Color(hex: "#4285F4"))
                                    Text("Continue with Google")
                                        .font(FloatFont.headline())
                                        .foregroundStyle(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(.white)
                                .cornerRadius(FloatSpacing.buttonRadius)
                            }
                            
                            // Divider
                            HStack {
                                Rectangle().frame(height: 0.5).foregroundStyle(FloatColors.textSecondary.opacity(0.4))
                                Text("or").font(FloatFont.caption()).foregroundStyle(FloatColors.textSecondary)
                                Rectangle().frame(height: 0.5).foregroundStyle(FloatColors.textSecondary.opacity(0.4))
                            }
                            
                            // Email fields toggle
                            if showEmailFields {
                                VStack(spacing: FloatSpacing.sm) {
                                    FloatTextField("Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                                    FloatTextField("Password", text: $password, icon: "lock", isSecure: true)
                                    
                                    FloatButton("Sign In with Email", isLoading: authService.isLoading) {
                                        Task { await authService.signInWithEmail(email: email, password: password) }
                                    }
                                    
                                    Button("Forgot password?") {
                                        showForgotPassword = true
                                    }
                                    .font(FloatFont.caption())
                                    .foregroundStyle(FloatColors.textSecondary)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            } else {
                                Button("Sign in with Email") {
                                    withAnimation(.easeInOut(duration: 0.3)) { showEmailFields = true }
                                }
                                .font(FloatFont.callout())
                                .foregroundStyle(FloatColors.textSecondary)
                            }
                        }
                        .padding(.horizontal, FloatSpacing.lg)
                        
                        // Error
                        if let error = authService.authError {
                            Text(error)
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.error)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, FloatSpacing.lg)
                                .padding(.top, FloatSpacing.sm)
                        }
                        
                        Spacer(minLength: FloatSpacing.xl)
                        
                        // Sign up
                        HStack(spacing: FloatSpacing.xs) {
                            Text("New to Float?")
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.textSecondary)
                            Button("Create account") { showSignUp = true }
                                .font(FloatFont.caption(.semibold))
                                .foregroundStyle(FloatColors.primary)
                        }
                        .padding(.bottom, FloatSpacing.xl)
                    }
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

// MARK: - Supporting TextField Component
struct FloatTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure = false
    
    init(_ placeholder: String, text: Binding<String>, icon: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
        self.placeholder = placeholder; self._text = text; self.icon = icon; self.keyboardType = keyboardType; self.isSecure = isSecure
    }
    
    var body: some View {
        HStack(spacing: FloatSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(FloatColors.textSecondary)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundStyle(.white)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
            }
        }
        .padding(FloatSpacing.md)
        .background(FloatColors.cardBackground)
        .cornerRadius(FloatSpacing.buttonRadius)
        .overlay(RoundedRectangle(cornerRadius: FloatSpacing.buttonRadius).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

struct ForgotPasswordView: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var sent = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: FloatSpacing.lg) {
                Image(systemName: "envelope.badge").font(.system(size: 48)).foregroundStyle(FloatColors.primary)
                Text("Reset Password").font(FloatFont.title())
                Text("Enter your email and we'll send you a link to reset your password.")
                    .font(FloatFont.body()).foregroundStyle(FloatColors.textSecondary).multilineTextAlignment(.center)
                
                if sent {
                    Text("✅ Check your inbox!").font(FloatFont.headline()).foregroundStyle(FloatColors.success)
                } else {
                    FloatTextField("Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                    FloatButton("Send Reset Link", isLoading: authService.isLoading) {
                        Task {
                            await authService.resetPassword(email: email)
                            sent = true
                        }
                    }
                }
            }
            .padding(FloatSpacing.lg)
            .floatScreenBackground()
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
        }
    }
}
