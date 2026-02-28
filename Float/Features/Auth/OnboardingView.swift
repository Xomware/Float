import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var locationService = LocationService()
    @StateObject private var notificationService = NotificationService()
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            FloatColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Step indicator
                HStack(spacing: FloatSpacing.sm) {
                    ForEach(0..<3) { i in
                        Capsule()
                            .fill(i <= currentStep ? FloatColors.primary : FloatColors.cardBackground)
                            .frame(width: i == currentStep ? 32 : 8, height: 8)
                            .animation(.spring(duration: 0.4), value: currentStep)
                    }
                }
                .padding(.top, FloatSpacing.xl)
                
                TabView(selection: $currentStep) {
                    OnboardingStep1View(locationService: locationService) { currentStep = 1 }
                        .tag(0)
                    OnboardingStep2View(notificationService: notificationService) { currentStep = 2 }
                        .tag(1)
                    OnboardingStep3View { username, displayName in
                        Task { try? await authService.updateProfile(username: username, displayName: displayName) }
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
        }
    }
}

// MARK: - Step 1: Location
struct OnboardingStep1View: View {
    let locationService: LocationService
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: FloatSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle().fill(FloatColors.primary.opacity(0.15)).frame(width: 140, height: 140)
                Image(systemName: "location.fill.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(FloatColors.primary)
            }
            
            VStack(spacing: FloatSpacing.sm) {
                Text("Deals Near You").font(FloatFont.title())
                Text("Float uses your location to surface live deals at bars and restaurants within walking distance. We never share your location.")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.lg)
            }
            
            Spacer()
            
            VStack(spacing: FloatSpacing.sm) {
                FloatButton("Enable Location", icon: "location.fill") {
                    locationService.requestPermission()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { onNext() }
                }
                Button("Not Now") { onNext() }
                    .font(FloatFont.callout())
                    .foregroundStyle(FloatColors.textSecondary)
            }
            .padding(.horizontal, FloatSpacing.lg)
            .padding(.bottom, FloatSpacing.xxl)
        }
    }
}

// MARK: - Step 2: Notifications
struct OnboardingStep2View: View {
    let notificationService: NotificationService
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: FloatSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle().fill(FloatColors.accent.opacity(0.15)).frame(width: 140, height: 140)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(FloatColors.accent)
            }
            
            VStack(spacing: FloatSpacing.sm) {
                Text("Never Miss a Deal").font(FloatFont.title())
                Text("Get notified when a great deal goes live near you, or when a deal you love is expiring soon. Max 2 alerts per day.")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.lg)
            }
            
            Spacer()
            
            VStack(spacing: FloatSpacing.sm) {
                FloatButton("Turn On Notifications", icon: "bell.fill") {
                    Task {
                        await notificationService.requestPermission()
                        onNext()
                    }
                }
                Button("Not Now") { onNext() }
                    .font(FloatFont.callout())
                    .foregroundStyle(FloatColors.textSecondary)
            }
            .padding(.horizontal, FloatSpacing.lg)
            .padding(.bottom, FloatSpacing.xxl)
        }
    }
}

// MARK: - Step 3: Profile Setup
struct OnboardingStep3View: View {
    let onComplete: (String, String) -> Void
    
    @State private var displayName = ""
    @State private var username = ""
    @State private var usernameError: String?
    
    private var isValid: Bool { !displayName.isEmpty && username.count >= 3 && !username.contains(" ") }
    
    var body: some View {
        VStack(spacing: FloatSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle().fill(FloatColors.success.opacity(0.15)).frame(width: 140, height: 140)
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(FloatColors.success)
            }
            
            VStack(spacing: FloatSpacing.sm) {
                Text("Set Up Your Profile").font(FloatFont.title())
                Text("Choose a display name and username so friends can find you.")
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, FloatSpacing.lg)
            }
            
            VStack(spacing: FloatSpacing.sm) {
                FloatTextField("Display Name", text: $displayName, icon: "person")
                
                VStack(alignment: .leading, spacing: 4) {
                    FloatTextField("Username (no spaces)", text: $username, icon: "at")
                        .onChange(of: username) { _, new in
                            username = new.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "_" }
                            usernameError = new.count > 0 && new.count < 3 ? "Username must be at least 3 characters" : nil
                        }
                    if let error = usernameError {
                        Text(error).font(FloatFont.caption()).foregroundStyle(FloatColors.error).padding(.leading, FloatSpacing.sm)
                    }
                }
            }
            .padding(.horizontal, FloatSpacing.lg)
            
            Spacer()
            
            VStack(spacing: FloatSpacing.sm) {
                FloatButton("Let's Float! 🍹", style: .primary) {
                    guard isValid else { return }
                    onComplete(username, displayName)
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.5)
                
                Button("Skip for now") { onComplete("", "") }
                    .font(FloatFont.callout())
                    .foregroundStyle(FloatColors.textSecondary)
            }
            .padding(.horizontal, FloatSpacing.lg)
            .padding(.bottom, FloatSpacing.xxl)
        }
    }
}
