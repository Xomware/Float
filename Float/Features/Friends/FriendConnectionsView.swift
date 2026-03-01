import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "FriendConnections")

@MainActor
final class FriendConnectionsViewModel: ObservableObject {
    @Published var friends: [UserProfile] = []
    @Published var pendingRequests: [FriendConnection] = []
    @Published var searchResults: [UserProfile] = []
    @Published var searchQuery = ""
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var errorMessage: String?

    private let friendService: FriendService

    init(friendService: FriendService = .shared) {
        self.friendService = friendService
    }

    func loadFriends() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let f = friendService.fetchFriends()
            async let p = friendService.fetchPendingRequests()
            friends = try await f
            pendingRequests = try await p
        } catch {
            logger.error("Failed to load friends: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    func searchUsers() async {
        guard searchQuery.count >= 2 else { searchResults = []; return }
        isSearching = true
        defer { isSearching = false }
        do { searchResults = try await friendService.searchUsers(query: searchQuery) }
        catch { logger.error("Search failed: \(error.localizedDescription)") }
    }

    func sendRequest(to userId: UUID) async {
        do {
            try await friendService.sendFriendRequest(userId: userId)
            searchResults.removeAll { $0.id == userId }
        } catch { errorMessage = "Failed to send request" }
    }

    func acceptRequest(_ request: FriendConnection) async {
        do {
            try await friendService.acceptFriendRequest(requestId: request.id)
            pendingRequests.removeAll { $0.id == request.id }
            await loadFriends()
        } catch { errorMessage = "Failed to accept request" }
    }

    func declineRequest(_ request: FriendConnection) async {
        do {
            try await friendService.declineFriendRequest(requestId: request.id)
            pendingRequests.removeAll { $0.id == request.id }
        } catch { errorMessage = "Failed to decline request" }
    }
}

struct FriendConnectionsView: View {
    @StateObject private var viewModel = FriendConnectionsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    TextField("Search by username", text: $viewModel.searchQuery)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit { Task { await viewModel.searchUsers() } }
                    if viewModel.isSearching { ProgressView().scaleEffect(0.8) }
                }
            } header: { Text("Find Friends") }

            if !viewModel.searchResults.isEmpty {
                Section("Search Results") {
                    ForEach(viewModel.searchResults) { user in
                        HStack {
                            userRow(user)
                            Spacer()
                            Button { Task { await viewModel.sendRequest(to: user.id) } } label: {
                                Image(systemName: "person.badge.plus").foregroundStyle(FloatColors.primary)
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }

            if !viewModel.pendingRequests.isEmpty {
                Section("Pending Requests") {
                    ForEach(viewModel.pendingRequests) { request in
                        HStack {
                            Text(request.requesterId.uuidString.prefix(8) + "...")
                                .font(FloatFont.body())
                            Spacer()
                            Button { Task { await viewModel.acceptRequest(request) } } label: {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.title3)
                            }.buttonStyle(.plain)
                            Button { Task { await viewModel.declineRequest(request) } } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.red).font(.title3)
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }

            Section("Friends (\(viewModel.friends.count))") {
                if viewModel.friends.isEmpty && !viewModel.isLoading {
                    Text("No friends yet. Search to connect!")
                        .font(FloatFont.body())
                        .foregroundStyle(FloatColors.adaptiveTextSecondary)
                } else {
                    ForEach(viewModel.friends) { friend in userRow(friend) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
        }
        .task { await viewModel.loadFriends() }
        .onChange(of: viewModel.searchQuery) { _ in
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                await viewModel.searchUsers()
            }
        }
    }

    @ViewBuilder
    private func userRow(_ user: UserProfile) -> some View {
        HStack(spacing: FloatSpacing.md) {
            ZStack {
                Circle().fill(FloatColors.primary.opacity(0.15)).frame(width: 36, height: 36)
                Text(String((user.displayName ?? user.username ?? "?").prefix(1)).uppercased())
                    .font(FloatFont.body(.semibold)).foregroundStyle(FloatColors.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName ?? "Float User").font(FloatFont.body(.semibold))
                if let username = user.username {
                    Text("@\(username)").font(FloatFont.caption()).foregroundStyle(FloatColors.adaptiveTextSecondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { FriendConnectionsView() }.preferredColorScheme(.dark)
}
