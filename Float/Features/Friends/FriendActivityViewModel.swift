import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "FriendActivityVM")

@MainActor
final class FriendActivityViewModel: ObservableObject {
    @Published var activityItems: [FriendActivityItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLoaded = false

    private let friendService: FriendService
    var isEmpty: Bool { hasLoaded && activityItems.isEmpty }

    init(friendService: FriendService = .shared) {
        self.friendService = friendService
    }

    func loadActivity() async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false; hasLoaded = true }
        do {
            activityItems = try await friendService.fetchFriendActivity(limit: 30)
        } catch {
            logger.error("Failed to load activity: \(error.localizedDescription)")
            errorMessage = "Couldn't load friend activity. Pull to retry."
        }
    }

    func toggleLike(for item: FriendActivityItem) async {
        guard let i = activityItems.firstIndex(where: { $0.id == item.id }) else { return }
        activityItems[i].isLiked.toggle()
        activityItems[i].likeCount += activityItems[i].isLiked ? 1 : -1
        do {
            let liked = try await friendService.toggleLike(redemptionId: item.redemptionId)
            activityItems[i].isLiked = liked
        } catch {
            activityItems[i].isLiked.toggle()
            activityItems[i].likeCount += activityItems[i].isLiked ? 1 : -1
        }
    }

    func refresh() async { await loadActivity() }
}
