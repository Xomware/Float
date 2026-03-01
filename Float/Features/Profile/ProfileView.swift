// ProfileView.swift
// Float

import SwiftUI

// MARK: - ProfileViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var isEditing = false
    @Published var editName = ""
    @Published var editBio = ""
    @Published var recentRedemptions: [MockRedemption] = []
    @Published var totalSaved: Double = 0

    struct MockRedemption: Identifiable {
        let id = UUID()
        let dealTitle: String
        let venueName: String
        let savings: Double
        let date: Date
        let category: String
    }

    func load(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(nanoseconds: 500_000_000)

        let prefs = NotificationPrefs.default
        profile = UserProfile(
            id: UUID(uuidString: userId) ?? UUID(),
            username: "floater",
            displayName: "Float User",
            avatarUrl: nil,
            bio: "Living for happy hour 🍹",
            locationCity: "Nashville",
            locationState: "TN",
            totalRedemptions: 12,
            totalSavings: 87.50,
            notificationPrefs: prefs,
            isMerchant: false,
            createdAt: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        )

        recentRedemptions = [
            MockRedemption(dealTitle: "2-for-1 Cocktails", venueName: "The Daily Brew", savings: 12.00,
                           date: Date().addingTimeInterval(-86400), category: "drink"),
            MockRedemption(dealTitle: "50% Off Nachos", venueName: "Food Court Pro", savings: 8.50,
                           date: Date().addingTimeInterval(-172800), category: "food"),
            MockRedemption(dealTitle: "30% Off Draft Beers", venueName: "Happy Hour Haven", savings: 6.00,
                           date: Date().addingTimeInterval(-345600), category: "drink"),
            MockRedemption(dealTitle: "Flash: $3 Shots", venueName: "Late Night Eats", savings: 5.00,
                           date: Date().addingTimeInterval(-518400), category: "flash")
        ]
        totalSaved = recentRedemptions.reduce(0) { $0 + $1.savings }
        editName = profile?.displayName ?? ""
        editBio = profile?.bio ?? ""
        AnalyticsService.shared.track(.profileViewed)
    }

    func saveEdits() async {
        guard let current = profile else { return }
        profile = UserProfile(
            id: current.id, username: current.username,
            displayName: editName.isEmpty ? current.displayName : editName,
            avatarUrl: current.avatarUrl, bio: editBio,
            locationCity: current.locationCity, locationState: current.locationState,
            totalRedemptions: current.totalRedemptions, totalSavings: current.totalSavings,
            notificationPrefs: current.notificationPrefs, isMerchant: current.isMerchant,
            createdAt: current.createdAt
        )
        isEditing = false
    }
}

// MARK: - ProfileView

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authService: AuthService
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProfileSkeletonView()
                } else if let profile = viewModel.profile {
                    profileContent(profile)
                } else {
                    signInPrompt
                }
            }
            .background(FloatColors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel.profile != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
        }
        .task {
            let userId = authService.currentUser?.id.uuidString ?? UUID().uuidString
            await viewModel.load(userId: userId)
        }
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirm) {
            Button("Sign Out", role: .destructive) { }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .confirmationDialog("Delete Account", isPresented: $showDeleteConfirm) {
            Button("Delete Account", role: .destructive) { }
        } message: {
            Text("This action is permanent and cannot be undone.")
        }
    }

    // MARK: - Profile Content

    @ViewBuilder
    private func profileContent(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: FloatSpacing.lg) {
                avatarSection(profile).padding(.top, FloatSpacing.md)
                statsRow(profile).padding(.horizontal, FloatSpacing.md)

                if viewModel.isEditing {
                    editSection
                        .padding(.horizontal, FloatSpacing.md)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if !viewModel.recentRedemptions.isEmpty {
                    redemptionsSection.padding(.horizontal, FloatSpacing.md)
                }

                accountActionsSection
                    .padding(.horizontal, FloatSpacing.md)
                    .padding(.bottom, FloatSpacing.xl)
            }
        }
        .refreshable {
            let userId = authService.currentUser?.id.uuidString ?? UUID().uuidString
            await viewModel.load(userId: userId)
        }
    }

    // MARK: - Avatar Section

    @ViewBuilder
    private func avatarSection(_ profile: UserProfile) -> some View {
        VStack(spacing: FloatSpacing.md) {
            ZStack {
                Circle()
                    .fill(FloatColors.primary.opacity(0.2))
                    .frame(width: 90, height: 90)
                Text(initials(for: profile.displayName ?? profile.username ?? "F"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(FloatColors.primary)
            }
            .accessibilityLabel("Avatar for \(profile.displayName ?? "user")")

            VStack(spacing: FloatSpacing.xs) {
                Text(profile.displayName ?? profile.username ?? "Float User")
                    .font(FloatFont.title())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)

                if let city = profile.locationCity, let state = profile.locationState {
                    HStack(spacing: FloatSpacing.xs) {
                        Image(systemName: "location.fill").font(.caption)
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        Text("\(city), \(state)")
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }
                }

                if let bio = profile.bio, !bio.isEmpty {
                    Text(bio)
                        .font(FloatFont.body())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, FloatSpacing.xl)
                }
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.isEditing.toggle()
                }
            } label: {
                Text(viewModel.isEditing ? "Cancel" : "Edit Profile")
                    .font(FloatFont.caption(.semibold))
                    .padding(.horizontal, FloatSpacing.md)
                    .padding(.vertical, 8)
                    .background(FloatColors.adaptiveCardBackground)
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(FloatColors.adaptiveSeparator, lineWidth: 1))
            }
        }
    }

    // MARK: - Stats Row

    @ViewBuilder
    private func statsRow(_ profile: UserProfile) -> some View {
        HStack(spacing: FloatSpacing.sm) {
            statCard(value: "\(profile.totalRedemptions)", label: "Redeemed",
                     icon: "tag.fill", color: FloatColors.primary)
            statCard(value: "$\(String(format: "%.0f", profile.totalSavings))", label: "Saved",
                     icon: "dollarsign.circle.fill", color: FloatColors.success)
            statCard(value: memberSince(profile.createdAt), label: "Member",
                     icon: "calendar", color: FloatColors.accent)
        }
    }

    @ViewBuilder
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: FloatSpacing.xs) {
            Image(systemName: icon).font(.system(size: 20)).foregroundStyle(color)
            Text(value).font(FloatFont.headline()).foregroundStyle(FloatColors.adaptiveTextPrimary)
            Text(label).font(FloatFont.caption2()).foregroundStyle(FloatColors.adaptiveTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FloatSpacing.md)
        .background(FloatColors.adaptiveCardBackground)
        .cornerRadius(12)
    }

    // MARK: - Edit Section

    private var editSection: some View {
        VStack(alignment: .leading, spacing: FloatSpacing.md) {
            Text("Edit Profile")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)

            VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                Text("Display Name")
                    .font(FloatFont.caption(.semibold))
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                TextField("Your name", text: $viewModel.editName)
                    .font(FloatFont.body())
                    .padding(10)
                    .background(FloatColors.adaptiveCardBackground)
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                Text("Bio")
                    .font(FloatFont.caption(.semibold))
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
                TextField("Tell us about yourself", text: $viewModel.editBio, axis: .vertical)
                    .font(FloatFont.body())
                    .lineLimit(3)
                    .padding(10)
                    .background(FloatColors.adaptiveCardBackground)
                    .cornerRadius(10)
            }

            FloatButton("Save Changes", style: .primary) {
                Task { await viewModel.saveEdits() }
            }
        }
        .padding(FloatSpacing.md)
        .background(FloatColors.adaptiveCardBackground)
        .cornerRadius(16)
    }

    // MARK: - Redemptions

    private var redemptionsSection: some View {
        VStack(alignment: .leading, spacing: FloatSpacing.md) {
            HStack {
                Text("Recent Redemptions")
                    .font(FloatFont.headline())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                Spacer()
                Text("$\(String(format: "%.2f", viewModel.totalSaved)) saved")
                    .font(FloatFont.caption(.semibold))
                    .foregroundStyle(FloatColors.success)
            }

            VStack(spacing: FloatSpacing.sm) {
                ForEach(viewModel.recentRedemptions.prefix(5)) { r in
                    HStack(spacing: FloatSpacing.md) {
                        ZStack {
                            Circle()
                                .fill(categoryColor(r.category).opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: categoryIcon(r.category))
                                .font(.system(size: 14))
                                .foregroundStyle(categoryColor(r.category))
                        }
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(r.dealTitle)
                                .font(FloatFont.body())
                                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                                .lineLimit(1)
                            Text(r.venueName)
                                .font(FloatFont.caption())
                                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("-$\(String(format: "%.2f", r.savings))")
                                .font(FloatFont.caption(.semibold))
                                .foregroundStyle(FloatColors.success)
                            Text(r.date, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                        }
                    }
                    .padding(.vertical, FloatSpacing.xs)

                    if r.id != viewModel.recentRedemptions.prefix(5).last?.id {
                        Divider().background(FloatColors.adaptiveSeparator)
                    }
                }
            }
            .padding(FloatSpacing.md)
            .background(FloatColors.adaptiveCardBackground)
            .cornerRadius(16)
        }
    }

    // MARK: - Account Actions

    private var accountActionsSection: some View {
        VStack(spacing: FloatSpacing.sm) {
            actionRow(icon: "arrow.right.square", title: "Sign Out", color: FloatColors.warning) {
                showSignOutConfirm = true
            }
            actionRow(icon: "trash", title: "Delete Account", color: FloatColors.error) {
                showDeleteConfirm = true
            }
        }
    }

    @ViewBuilder
    private func actionRow(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: FloatSpacing.md) {
                Image(systemName: icon).font(.system(size: 16)).foregroundStyle(color).frame(width: 28)
                Text(title).font(FloatFont.body()).foregroundStyle(color)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(FloatColors.adaptiveTextSecondary)
            }
            .padding(.horizontal, FloatSpacing.md)
            .padding(.vertical, FloatSpacing.md)
            .background(FloatColors.adaptiveCardBackground)
            .cornerRadius(12)
        }
    }

    // MARK: - Sign-in Prompt

    private var signInPrompt: some View {
        VStack(spacing: FloatSpacing.lg) {
            Spacer()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(FloatColors.primary)
            Text("Your Profile")
                .font(FloatFont.title())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
            Text("Sign in to track your savings and view redemption history")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FloatSpacing.xl)
            FloatButton("Sign In to Float", icon: "person.fill", style: .primary) { }
                .padding(.horizontal, FloatSpacing.xl)
            Spacer()
        }
    }

    // MARK: - Helpers

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.map { String($0.prefix(1)) }.joined().uppercased()
    }

    private func memberSince(_ date: Date) -> String {
        let months = Calendar.current.dateComponents([.month], from: date, to: Date()).month ?? 0
        return months < 1 ? "New" : "\(months)mo"
    }

    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "drink": return FloatColors.drinkColor
        case "food":  return FloatColors.foodColor
        case "both":  return FloatColors.comboColor
        case "flash": return FloatColors.eventColor
        default:      return FloatColors.primary
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "drink": return "wineglass.fill"
        case "food":  return "fork.knife"
        case "both":  return "party.popper.fill"
        case "flash": return "bolt.fill"
        default:      return "tag.fill"
        }
    }
}

// MARK: - ProfileSkeletonView

struct ProfileSkeletonView: View {
    var body: some View {
        VStack(spacing: FloatSpacing.lg) {
            Circle().fill(Color.gray.opacity(0.3)).frame(width: 90, height: 90)
            RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.3)).frame(width: 140, height: 20)
            RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)).frame(width: 200, height: 16)
            HStack(spacing: FloatSpacing.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(maxWidth: .infinity).frame(height: 80)
                }
            }
            .padding(.horizontal, FloatSpacing.md)
        }
        .padding(.top, FloatSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
        .preferredColorScheme(.dark)
}
