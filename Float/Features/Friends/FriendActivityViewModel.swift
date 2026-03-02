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
        isLoading = true
        errorMessage = nil
        defer { isLoading = false; hasLoaded = true }

        do {
            activityItems = try await friendService.fetchFriendActivity(limit: 30)
            logger.info("Loaded \(self.activityItems.count) activity items")
        } catch {
            logger.error("Failed to load activity: \(error.localizedDescription)")
            errorMessage = "Couldn't load friend activity. Pull to retry."
        }
    }

    func toggleLike(for item: FriendActivityItem) async {
        guard let index = activityItems.firstIndex(where: { $0.id == item.id }) else { return }
        activityItems[index].isLiked.toggle()
        activityItems[index].likeCount += activityItems[index].isLiked ? 1 : -1

        do {
            let isNowLiked = try await friendService.toggleLike(redemptionId: item.redemptionId)
            activityItems[index].isLiked = isNowLiked
        } catch {
            activityItems[index].isLiked.toggle()
            activityItems[index].likeCount += activityItems[index].isLiked ? 1 : -1
            logger.error("Failed to toggle like: \(error.localizedDescription)")
        }
    }

    func refresh() async { await loadActivity() }
}
