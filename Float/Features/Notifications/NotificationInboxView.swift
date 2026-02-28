import SwiftUI

// MARK: - NotificationInboxView

/// In-app notification history screen.
/// Displays push notifications sent to the current user.
struct NotificationInboxView: View {

    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = NotificationInboxViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Mark All Read") {
                            Task { await viewModel.markAllRead() }
                        }
                        .disabled(viewModel.unreadCount == 0)
                    }
                }
            }
        }
        .task {
            if let userId = authService.currentUser?.id.uuidString {
                await viewModel.load(userId: userId)
            }
        }
    }

    // MARK: - Subviews

    private var notificationList: some View {
        List {
            ForEach(viewModel.notifications) { entry in
                NotificationRowView(entry: entry)
                    .listRowBackground(entry.isRead ? Color.clear : Color.accentColor.opacity(0.08))
                    .swipeActions {
                        if !entry.isRead {
                            Button("Read") {
                                Task { await viewModel.markRead(entry: entry) }
                            }
                            .tint(.accentColor)
                        }
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            if let userId = authService.currentUser?.id.uuidString {
                await viewModel.load(userId: userId)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No notifications yet")
                .font(.headline)
            Text("We'll notify you when favorited venues post deals or your saved deals are expiring.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - NotificationRowView

struct NotificationRowView: View {
    let entry: NotificationLogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.system(size: 22))
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .font(.subheadline.weight(entry.isRead ? .regular : .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(entry.sentAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(entry.body)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch entry.notificationType {
        case "favorited_venue_new_deal": return "star.fill"
        case "geofence_nearby_deal":    return "location.fill"
        case "deal_expiring_soon":      return "clock.fill"
        default:                        return "bell.fill"
        }
    }

    private var iconColor: Color {
        switch entry.notificationType {
        case "favorited_venue_new_deal": return .yellow
        case "geofence_nearby_deal":    return .blue
        case "deal_expiring_soon":      return .orange
        default:                        return .accentColor
        }
    }
}

// MARK: - NotificationInboxViewModel

@MainActor
final class NotificationInboxViewModel: ObservableObject {

    @Published var notifications: [NotificationLogEntry] = []
    @Published var isLoading = false
    @Published var unreadCount = 0

    private let service = NotificationService.shared

    func load(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        notifications = await service.fetchNotificationHistory(userId: userId)
        unreadCount = notifications.filter { !$0.isRead }.count
    }

    func markRead(entry: NotificationLogEntry) async {
        // Optimistic update
        if let idx = notifications.firstIndex(where: { $0.id == entry.id }) {
            notifications[idx] = NotificationLogEntry(
                id: entry.id,
                userId: entry.userId,
                notificationType: entry.notificationType,
                title: entry.title,
                body: entry.body,
                dealId: entry.dealId,
                venueId: entry.venueId,
                sentAt: entry.sentAt,
                isRead: true
            )
            unreadCount = notifications.filter { !$0.isRead }.count
        }

        // Persist to Supabase
        do {
            try await SupabaseClientService.shared.client
                .from("notification_log")
                .update(["is_read": true])
                .eq("id", value: entry.id.uuidString)
                .execute()
        } catch {
            // Revert on failure — reload
            await load(userId: entry.userId.uuidString)
        }
    }

    func markAllRead() async {
        guard let firstEntry = notifications.first else { return }
        let userId = firstEntry.userId.uuidString

        notifications = notifications.map { entry in
            NotificationLogEntry(
                id: entry.id,
                userId: entry.userId,
                notificationType: entry.notificationType,
                title: entry.title,
                body: entry.body,
                dealId: entry.dealId,
                venueId: entry.venueId,
                sentAt: entry.sentAt,
                isRead: true
            )
        }
        unreadCount = 0

        do {
            try await SupabaseClientService.shared.client
                .from("notification_log")
                .update(["is_read": true])
                .eq("user_id", value: userId)
                .eq("is_read", value: false)
                .execute()
        } catch {
            await load(userId: userId)
        }
    }
}
