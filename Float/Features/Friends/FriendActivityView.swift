import SwiftUI

struct FriendActivityView: View {
    @StateObject private var viewModel = FriendActivityViewModel()
    @State private var showFriendConnections = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && !viewModel.hasLoaded {
                    loadingView
                } else if viewModel.isEmpty {
                    emptyStateView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else {
                    activityList
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showFriendConnections = true } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(FloatColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showFriendConnections) {
                NavigationStack { FriendConnectionsView() }
            }
            .task { await viewModel.loadActivity() }
        }
    }

    private var activityList: some View {
        List {
            ForEach(viewModel.activityItems) { item in
                FriendActivityRow(item: item) {
                    Task { await viewModel.toggleLike(for: item) }
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
    }

    private var emptyStateView: some View {
        VStack(spacing: FloatSpacing.lg) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 56))
                .foregroundStyle(FloatColors.primary.opacity(0.5))
            Text("Connect with friends\nto see their activity")
                .font(FloatFont.headline())
                .foregroundStyle(FloatColors.adaptiveTextPrimary)
                .multilineTextAlignment(.center)
            Text("See what deals your friends are redeeming nearby")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
            Button { showFriendConnections = true } label: {
                Label("Find Friends", systemImage: "magnifyingglass")
                    .font(FloatFont.body(.semibold))
                    .padding(.horizontal, FloatSpacing.xl)
                    .padding(.vertical, FloatSpacing.md)
                    .background(FloatColors.primary)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(FloatSpacing.xl)
    }

    private var loadingView: some View {
        VStack(spacing: FloatSpacing.md) {
            ProgressView().tint(FloatColors.primary)
            Text("Loading activity...")
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: FloatSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(FloatColors.warning)
            Text(message)
                .font(FloatFont.body())
                .foregroundStyle(FloatColors.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") { Task { await viewModel.loadActivity() } }
                .buttonStyle(.borderedProminent)
                .tint(FloatColors.primary)
        }
        .padding()
    }
}

// MARK: - Activity Row

struct FriendActivityRow: View {
    let item: FriendActivityItem
    let onLike: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: FloatSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(FloatColors.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                if let avatarUrl = item.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Text(String(item.displayName.prefix(1)).uppercased())
                            .font(FloatFont.headline())
                            .foregroundStyle(FloatColors.primary)
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                } else {
                    Text(String(item.displayName.prefix(1)).uppercased())
                        .font(FloatFont.headline())
                        .foregroundStyle(FloatColors.primary)
                }
            }

            VStack(alignment: .leading, spacing: FloatSpacing.xs) {
                Text(activityText)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                Text(item.redeemedAt.relativeFormat())
                    .font(FloatFont.caption())
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)
            }

            Spacer()

            Button(action: onLike) {
                VStack(spacing: 2) {
                    Image(systemName: item.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(item.isLiked ? .red : FloatColors.adaptiveTextSecondary)
                        .font(.system(size: 18))
                    if item.likeCount > 0 {
                        Text("\(item.likeCount)")
                            .font(FloatFont.caption())
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(FloatSpacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var activityText: AttributedString {
        var result = AttributedString(item.displayName)
        result.font = FloatFont.body(.semibold)
        result += AttributedString(" redeemed ")
        var deal = AttributedString(item.dealTitle)
        deal.font = FloatFont.body(.semibold)
        result += deal
        result += AttributedString(" at ")
        var venue = AttributedString(item.venueName)
        venue.font = FloatFont.body(.semibold)
        result += venue
        return result
    }
}

#Preview {
    FriendActivityView().preferredColorScheme(.dark)
}
