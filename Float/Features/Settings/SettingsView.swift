// SettingsView.swift
// Float

import SwiftUI
import UserNotifications

// MARK: - SettingsViewModel

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var displayName = ""
    @Published var email = ""
    @Published var prefersDarkMode: AppearanceMode = .system
    @Published var useMetric = false
    @Published var defaultRadiusMiles: Double = 2.0
    @Published var isPrivateProfile = false
    @Published var dealExpiryReminders = true
    @Published var appVersion = ""
    @Published var buildNumber = ""

    enum AppearanceMode: String, CaseIterable {
        case system = "System"
        case dark = "Dark"
        case light = "Light"

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .dark: return .dark
            case .light: return .light
            }
        }
    }

    func load() {
        let defaults = UserDefaults.standard
        displayName = defaults.string(forKey: "user_display_name") ?? "Float User"
        email = defaults.string(forKey: "user_email") ?? "user@example.com"
        useMetric = defaults.bool(forKey: "use_metric")
        defaultRadiusMiles = defaults.double(forKey: "default_radius_miles").clamped(to: 0.25...10)
        if defaultRadiusMiles == 0 { defaultRadiusMiles = 2.0 }
        isPrivateProfile = defaults.bool(forKey: "is_private_profile")
        dealExpiryReminders = defaults.contains(key: "dealExpiryReminders")
            ? defaults.bool(forKey: "dealExpiryReminders")
            : true
        let rawMode = defaults.string(forKey: "appearance_mode") ?? "System"
        prefersDarkMode = AppearanceMode(rawValue: rawMode) ?? .system

        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    func save() {
        let defaults = UserDefaults.standard
        defaults.set(displayName, forKey: "user_display_name")
        defaults.set(useMetric, forKey: "use_metric")
        defaults.set(defaultRadiusMiles, forKey: "default_radius_miles")
        defaults.set(isPrivateProfile, forKey: "is_private_profile")
        defaults.set(dealExpiryReminders, forKey: "dealExpiryReminders")
        defaults.set(prefersDarkMode.rawValue, forKey: "appearance_mode")
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var authService: AuthService
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @Environment(\.openURL) var openURL

    var body: some View {
        List {

            // MARK: Account
            Section("Account") {
                settingsRow(icon: "person.fill", title: "Display Name", trailing: viewModel.displayName, color: FloatColors.primary) { }

                settingsRow(icon: "envelope.fill", title: "Email", trailing: viewModel.email, color: FloatColors.accent) { }

                NavigationLink(destination: NotificationPreferencesView()) {
                    settingsRowContent(icon: "bell.fill", title: "Notifications", color: FloatColors.warning)
                }

                Toggle(isOn: $viewModel.dealExpiryReminders) {
                    settingsRowContent(icon: "clock.badge.exclamationmark", title: "Deal Expiry Reminders", color: FloatColors.warning)
                }
                .tint(FloatColors.primary)
                .onChange(of: viewModel.dealExpiryReminders) { _ in
                    viewModel.save()
                    if !viewModel.dealExpiryReminders {
                        Task {
                            await NotificationScheduler.shared.cancelAllAlerts()
                        }
                    }
                }

                Toggle(isOn: $viewModel.isPrivateProfile) {
                    settingsRowContent(icon: "lock.fill", title: "Private Profile", color: .indigo)
                }
                .tint(FloatColors.primary)
                .onChange(of: viewModel.isPrivateProfile) { _ in viewModel.save() }
            }

            // MARK: Appearance
            Section("Appearance") {
                Picker(selection: $viewModel.prefersDarkMode) {
                    ForEach(SettingsViewModel.AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                } label: {
                    settingsRowContent(icon: "paintbrush.fill", title: "Theme", color: .purple)
                }
                .tint(FloatColors.primary)
                .onChange(of: viewModel.prefersDarkMode) { _ in viewModel.save() }
            }

            // MARK: Discovery
            Section("Discovery") {
                Toggle(isOn: $viewModel.useMetric) {
                    settingsRowContent(icon: "ruler.fill", title: "Use Kilometers", color: FloatColors.drinkColor)
                }
                .tint(FloatColors.primary)
                .onChange(of: viewModel.useMetric) { _ in viewModel.save() }

                VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                    let radiusFmt = viewModel.defaultRadiusMiles < 1 ? "%.2g" : "%.0f"
                    let radiusStr = String(format: radiusFmt, viewModel.defaultRadiusMiles)
                    let unit = viewModel.useMetric ? "km" : "mi"
                    settingsRowContent(
                        icon: "location.circle.fill",
                        title: "Default Radius: \(radiusStr) \(unit)",
                        color: FloatColors.foodColor
                    )
                    Slider(value: $viewModel.defaultRadiusMiles, in: 0.25...10, step: 0.25)
                        .tint(FloatColors.primary)
                        .padding(.top, FloatSpacing.xs)
                        .onChange(of: viewModel.defaultRadiusMiles) { _ in viewModel.save() }
                }
            }

            // MARK: Privacy
            Section("Privacy") {
                Button {
                    // Export request
                } label: {
                    settingsRowContent(icon: "square.and.arrow.up", title: "Export My Data", color: .teal)
                }
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                
                Button { showPrivacyPolicy = true } label: {
                    settingsRowContent(icon: "hand.raised.fill", title: "Privacy Policy", color: .green)
                }
                .foregroundStyle(FloatColors.adaptiveTextPrimary)

                Button { showTerms = true } label: {
                    settingsRowContent(icon: "doc.text.fill", title: "Terms of Service", color: .cyan)
                }
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
            }

            // MARK: About
            Section("About") {
                settingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    trailing: "\(viewModel.appVersion) (\(viewModel.buildNumber))",
                    color: FloatColors.adaptiveTextSecondary
                ) { }

                Button {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id0000000000?action=write-review") {
                        openURL(url)
                    }
                } label: {
                    settingsRowContent(icon: "star.fill", title: "Rate Float", color: FloatColors.warning)
                }
                .foregroundStyle(FloatColors.adaptiveTextPrimary)

                Button {
                    openURL(URL(string: "mailto:support@float.app")!)
                } label: {
                    settingsRowContent(icon: "envelope.fill", title: "Contact Support", color: .blue)
                }
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
            }

            // MARK: Danger Zone
            Section {
                Button {
                    showSignOutConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.square")
                            .foregroundStyle(FloatColors.warning)
                        Text("Sign Out")
                            .foregroundStyle(FloatColors.warning)
                    }
                }

                Button {
                    showDeleteConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(FloatColors.error)
                        Text("Delete Account")
                            .foregroundStyle(FloatColors.error)
                    }
                }
            // swiftlint:disable:next multiple_closures_with_trailing_closure
            } header: {
                Text("Danger Zone")
            } footer: {
                Text("Deleting your account is permanent and cannot be undone.")
                    .font(FloatFont.caption())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
            }

            #if DEBUG
            Section("Developer") {
                Button {
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
                } label: {
                    Label("Clear All Cache", systemImage: "trash")
                        .foregroundStyle(FloatColors.warning)
                }
                Button {
                    UserDefaults.standard.removeObject(forKey: "onboarding_complete")
                } label: {
                    Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                        .foregroundStyle(FloatColors.accent)
                }
            }
            #endif
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.load() }
        .trackScreen("Settings")
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirm, actions: {
            Button("Sign Out", role: .destructive) { /* authService.signOut() */ }
        }, message: { Text("Are you sure you want to sign out?") })
        .confirmationDialog("Delete Account", isPresented: $showDeleteConfirm, actions: {
            Button("Delete Account", role: .destructive) { }
        }, message: { Text("This is permanent and cannot be undone.") })
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://float.app/privacy")!)
        }
        .sheet(isPresented: $showTerms) {
            SafariView(url: URL(string: "https://float.app/terms")!)
        }
    }

    // MARK: Helpers

    @ViewBuilder
    private func settingsRowContent(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: FloatSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(color.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
            .accessibilityHidden(true)
            Text(title)
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
        }
    }

    @ViewBuilder
    private func settingsRow(icon: String, title: String, trailing: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                settingsRowContent(icon: icon, title: title, color: color)
                Spacer()
                Text(trailing)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
            }
        }
        .foregroundStyle(FloatColors.adaptiveTextPrimary)
    }
}

// MARK: - SafariView

import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthService())
    }
    .preferredColorScheme(.dark)
}
