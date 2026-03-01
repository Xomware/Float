// NotificationPreferencesView.swift
// Float

import SwiftUI
import UserNotifications

// MARK: - NotificationPreferencesViewModel

@MainActor
final class NotificationPreferencesViewModel: ObservableObject {
    @Published var dealsNearby = true
    @Published var expiringSoon = true
    @Published var newVenueDeals = false
    @Published var weeklyRoundup = true
    @Published var promotions = false
    @Published var quietHoursEnabled = false
    @Published var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @Published var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var isSaving = false

    func load() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionStatus = settings.authorizationStatus

        // Load from UserDefaults
        let defaults = UserDefaults.standard
        dealsNearby = defaults.object(forKey: "notif_deals_nearby") as? Bool ?? true
        expiringSoon = defaults.object(forKey: "notif_expiring_soon") as? Bool ?? true
        newVenueDeals = defaults.object(forKey: "notif_new_venue_deals") as? Bool ?? false
        weeklyRoundup = defaults.object(forKey: "notif_weekly_roundup") as? Bool ?? true
        promotions = defaults.object(forKey: "notif_promotions") as? Bool ?? false
        quietHoursEnabled = defaults.object(forKey: "notif_quiet_hours_enabled") as? Bool ?? false
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        let defaults = UserDefaults.standard
        defaults.set(dealsNearby, forKey: "notif_deals_nearby")
        defaults.set(expiringSoon, forKey: "notif_expiring_soon")
        defaults.set(newVenueDeals, forKey: "notif_new_venue_deals")
        defaults.set(weeklyRoundup, forKey: "notif_weekly_roundup")
        defaults.set(promotions, forKey: "notif_promotions")
        defaults.set(quietHoursEnabled, forKey: "notif_quiet_hours_enabled")

        // Track preference changes
        if !dealsNearby && !expiringSoon && !newVenueDeals && !weeklyRoundup {
            AnalyticsService.shared.track(.notificationsDisabled)
        } else {
            AnalyticsService.shared.track(.notificationsEnabled)
        }
    }

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            permissionStatus = settings.authorizationStatus
            if granted {
                AnalyticsService.shared.track(.notificationsEnabled)
            }
        } catch {
            // ignore
        }
    }
}

// MARK: - NotificationPreferencesView

struct NotificationPreferencesView: View {
    @StateObject private var viewModel = NotificationPreferencesViewModel()

    var body: some View {
        List {
            // Permission status
            if viewModel.permissionStatus == .denied {
                Section {
                    HStack(spacing: FloatSpacing.md) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(FloatColors.warning)
                        VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                            Text("Notifications Disabled")
                                .font(FloatFont.headline())
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                            Text("Enable in iOS Settings to receive deal alerts")
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        }
                    }
                    .padding(.vertical, FloatSpacing.xs)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundStyle(FloatColors.primary)
                }
            } else if viewModel.permissionStatus == .notDetermined {
                Section {
                    Button {
                        Task { await viewModel.requestPermission() }
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(FloatColors.primary)
                            Text("Enable Push Notifications")
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                        }
                    }
                }
            }

            // Deal alerts
            Section("Deal Alerts") {
                notifToggleRow(
                    title: "Nearby Deals",
                    subtitle: "When new deals appear within your radius",
                    icon: "location.fill",
                    color: FloatColors.accent,
                    value: $viewModel.dealsNearby
                )
                notifToggleRow(
                    title: "Expiring Soon",
                    subtitle: "2 hours before a saved deal expires",
                    icon: "clock.fill",
                    color: FloatColors.warning,
                    value: $viewModel.expiringSoon
                )
                notifToggleRow(
                    title: "Favorited Venue New Deals",
                    subtitle: "When a saved venue posts a new deal",
                    icon: "star.fill",
                    color: FloatColors.secondary,
                    value: $viewModel.newVenueDeals
                )
            }

            // Updates
            Section("Updates") {
                notifToggleRow(
                    title: "Weekly Roundup",
                    subtitle: "Best deals in your area every week",
                    icon: "newspaper.fill",
                    color: FloatColors.drinkColor,
                    value: $viewModel.weeklyRoundup
                )
                notifToggleRow(
                    title: "Promotions",
                    subtitle: "Special offers and Float announcements",
                    icon: "megaphone.fill",
                    color: FloatColors.comboColor,
                    value: $viewModel.promotions
                )
            }

            // Quiet hours
            Section("Quiet Hours") {
                Toggle(isOn: $viewModel.quietHoursEnabled) {
                    HStack(spacing: FloatSpacing.md) {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(.indigo)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quiet Hours")
                                .font(FloatFont.body())
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                            Text("Pause non-urgent notifications")
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        }
                    }
                }
                .tint(FloatColors.primary)

                if viewModel.quietHoursEnabled {
                    DatePicker("Start", selection: $viewModel.quietHoursStart, displayedComponents: .hourAndMinute)
                        .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    DatePicker("End", selection: $viewModel.quietHoursEnd, displayedComponents: .hourAndMinute)
                        .foregroundStyle(FloatColors.adaptiveTextPrimary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isSaving {
                    ProgressView().tint(FloatColors.primary)
                } else {
                    Button("Save") {
                        Task { await viewModel.save() }
                    }
                    .foregroundStyle(FloatColors.primary)
                    .fontWeight(.semibold)
                }
            }
        }
        .task { await viewModel.load() }
        .trackScreen("NotificationPreferences")
    }

    @ViewBuilder
    private func notifToggleRow(title: String, subtitle: String, icon: String, color: Color, value: Binding<Bool>) -> some View {
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

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                Text(subtitle)
                    .font(FloatFont.caption())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
            }

            Spacer()
            Toggle("", isOn: value)
                .tint(FloatColors.primary)
                .labelsHidden()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        NotificationPreferencesView()
    }
    .preferredColorScheme(.dark)
}
