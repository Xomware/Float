import Foundation
import Supabase
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Friends")

/// Service for friend connections and activity feed
final class FriendService {
    static let shared = FriendService()
    private let supabase = SupabaseClientService.shared.client

    private init() {}

    // MARK: - Friend Activity Feed

    /// Fetch recent redemptions by accepted friends
    func fetchFriendActivity(limit: Int = 20) async throws -> [FriendActivityItem] {
        guard let userId = try? await supabase.auth.session.user.id else {
            logger.warning("No authenticated user for friend activity")
            return []
        }

        // Get accepted friend IDs
        let friendIds = try await fetchAcceptedFriendIds(for: userId)
        guard !friendIds.isEmpty else { return [] }

        // Fetch redemptions by friends with joined data
        let response: [FriendActivityResponse] = try await supabase.database
            .from("redemptions")
            .select("id, user_id, deal_id, created_at, user_profiles!inner(id, username, display_name, avatar_url), deals!inner(id, title, venue_id), venues!inner(id, name)")
            .in("user_id", values: friendIds.map { $0.uuidString })
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value

        // Fetch likes for these redemptions
        let redemptionIds = response.map { $0.id }
        let likes = try await fetchLikesForRedemptions(redemptionIds)
        let userLikes = likes.filter { $0.userId == userId }.map { $0.redemptionId }
        let likeCounts = Dictionary(grouping: likes, by: \.redemptionId).mapValues(\.count)

        return response.map { item in
            FriendActivityItem(
                id: item.id,
                userId: item.userId,
                username: item.userProfile.username ?? "user",
                displayName: item.userProfile.displayName ?? "Float User",
                avatarUrl: item.userProfile.avatarUrl,
                dealId: item.deal.id,
                dealTitle: item.deal.title,
                venueName: item.venue.name,
                redeemedAt: item.createdAt,
                redemptionId: item.id,
                isLiked: userLikes.contains(item.id),
                likeCount: likeCounts[item.id] ?? 0
            )
        }
    }

    // MARK: - Likes

    func toggleLike(redemptionId: UUID) async throws -> Bool {
        let userId = try await supabase.auth.session.user.id

        // Check if already liked
        let existing: [ActivityLike] = try await supabase.database
            .from("activity_likes")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("redemption_id", value: redemptionId.uuidString)
            .execute()
            .value

        if existing.isEmpty {
            // Like it
            try await supabase.database
                .from("activity_likes")
                .insert(["user_id": userId.uuidString, "redemption_id": redemptionId.uuidString])
                .execute()
            logger.info("Liked redemption \(redemptionId)")
            return true
        } else {
            // Unlike it
            try await supabase.database
                .from("activity_likes")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("redemption_id", value: redemptionId.uuidString)
                .execute()
            logger.info("Unliked redemption \(redemptionId)")
            return false
        }
    }

    private func fetchLikesForRedemptions(_ ids: [UUID]) async throws -> [ActivityLike] {
        guard !ids.isEmpty else { return [] }
        return try await supabase.database
            .from("activity_likes")
            .select()
            .in("redemption_id", values: ids.map { $0.uuidString })
            .execute()
            .value
    }

    // MARK: - Friend Connections

    func fetchFriends() async throws -> [UserProfile] {
        let userId = try await supabase.auth.session.user.id
        let friendIds = try await fetchAcceptedFriendIds(for: userId)

        guard !friendIds.isEmpty else { return [] }

        return try await supabase.database
            .from("user_profiles")
            .select()
            .in("id", values: friendIds.map { $0.uuidString })
            .execute()
            .value
    }

    func sendFriendRequest(userId targetId: UUID) async throws {
        let userId = try await supabase.auth.session.user.id
        try await supabase.database
            .from("friend_connections")
            .insert([
                "requester_id": userId.uuidString,
                "addressee_id": targetId.uuidString,
                "status": "pending"
            ])
            .execute()
        logger.info("Sent friend request to \(targetId)")
    }

    func acceptFriendRequest(requestId: UUID) async throws {
        try await supabase.database
            .from("friend_connections")
            .update(["status": "accepted"])
            .eq("id", value: requestId.uuidString)
            .execute()
        logger.info("Accepted friend request \(requestId)")
    }

    func declineFriendRequest(requestId: UUID) async throws {
        try await supabase.database
            .from("friend_connections")
            .update(["status": "declined"])
            .eq("id", value: requestId.uuidString)
            .execute()
        logger.info("Declined friend request \(requestId)")
    }

    func removeFriend(connectionId: UUID) async throws {
        try await supabase.database
            .from("friend_connections")
            .delete()
            .eq("id", value: connectionId.uuidString)
            .execute()
        logger.info("Removed friend connection \(connectionId)")
    }

    func fetchPendingRequests() async throws -> [FriendConnection] {
        let userId = try await supabase.auth.session.user.id
        return try await supabase.database
            .from("friend_connections")
            .select()
            .eq("addressee_id", value: userId.uuidString)
            .eq("status", value: "pending")
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func searchUsers(query: String) async throws -> [UserProfile] {
        guard query.count >= 2 else { return [] }
        let userId = try await supabase.auth.session.user.id
        let results: [UserProfile] = try await supabase.database
            .from("user_profiles")
            .select()
            .ilike("username", value: "%\(query)%")
            .neq("id", value: userId.uuidString)
            .limit(20)
            .execute()
            .value
        return results
    }

    // MARK: - Helpers

    private func fetchAcceptedFriendIds(for userId: UUID) async throws -> [UUID] {
        let asRequester: [FriendConnection] = try await supabase.database
            .from("friend_connections")
            .select()
            .eq("requester_id", value: userId.uuidString)
            .eq("status", value: "accepted")
            .execute()
            .value

        let asAddressee: [FriendConnection] = try await supabase.database
            .from("friend_connections")
            .select()
            .eq("addressee_id", value: userId.uuidString)
            .eq("status", value: "accepted")
            .execute()
            .value

        let ids = asRequester.map(\.addresseeId) + asAddressee.map(\.requesterId)
        return Array(Set(ids))
    }
}
