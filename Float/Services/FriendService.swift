import Foundation
import Supabase
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Friends")

final class FriendService {
    static let shared = FriendService()
    private let supabase = SupabaseClientService.shared.client
    private init() {}

    func fetchFriendActivity(limit: Int = 20) async throws -> [FriendActivityItem] {
        guard let userId = try? await supabase.auth.session.user.id else { return [] }
        let friendIds = try await fetchAcceptedFriendIds(for: userId)
        guard !friendIds.isEmpty else { return [] }

        let response: [FriendActivityResponse] = try await supabase.database
            .from("redemptions")
            .select("id, user_id, deal_id, created_at, user_profiles!inner(id, username, display_name, avatar_url), deals!inner(id, title, venue_id), venues!inner(id, name)")
            .in("user_id", values: friendIds.map { $0.uuidString })
            .order("created_at", ascending: false)
            .limit(limit)
            .execute().value

        let redemptionIds = response.map { $0.id }
        let likes = try await fetchLikesForRedemptions(redemptionIds)
        let userLikes = Set(likes.filter { $0.userId == userId }.map { $0.redemptionId })
        let likeCounts = Dictionary(grouping: likes, by: \.redemptionId).mapValues(\.count)

        return response.map { item in
            FriendActivityItem(
                id: item.id, userId: item.userId,
                username: item.userProfile.username ?? "user",
                displayName: item.userProfile.displayName ?? "Float User",
                avatarUrl: item.userProfile.avatarUrl,
                dealId: item.deal.id, dealTitle: item.deal.title,
                venueName: item.venue.name, redeemedAt: item.createdAt,
                redemptionId: item.id,
                isLiked: userLikes.contains(item.id),
                likeCount: likeCounts[item.id] ?? 0)
        }
    }

    func toggleLike(redemptionId: UUID) async throws -> Bool {
        let userId = try await supabase.auth.session.user.id
        let existing: [ActivityLike] = try await supabase.database
            .from("activity_likes").select()
            .eq("user_id", value: userId.uuidString)
            .eq("redemption_id", value: redemptionId.uuidString)
            .execute().value
        if existing.isEmpty {
            try await supabase.database.from("activity_likes")
                .insert(["user_id": userId.uuidString, "redemption_id": redemptionId.uuidString])
                .execute()
            return true
        } else {
            try await supabase.database.from("activity_likes").delete()
                .eq("user_id", value: userId.uuidString)
                .eq("redemption_id", value: redemptionId.uuidString)
                .execute()
            return false
        }
    }

    private func fetchLikesForRedemptions(_ ids: [UUID]) async throws -> [ActivityLike] {
        guard !ids.isEmpty else { return [] }
        return try await supabase.database.from("activity_likes").select()
            .in("redemption_id", values: ids.map { $0.uuidString })
            .execute().value
    }

    func fetchFriends() async throws -> [UserProfile] {
        let userId = try await supabase.auth.session.user.id
        let friendIds = try await fetchAcceptedFriendIds(for: userId)
        guard !friendIds.isEmpty else { return [] }
        return try await supabase.database.from("user_profiles").select()
            .in("id", values: friendIds.map { $0.uuidString })
            .execute().value
    }

    func sendFriendRequest(userId targetId: UUID) async throws {
        let userId = try await supabase.auth.session.user.id
        try await supabase.database.from("friend_connections")
            .insert(["requester_id": userId.uuidString, "addressee_id": targetId.uuidString, "status": "pending"])
            .execute()
    }

    func acceptFriendRequest(requestId: UUID) async throws {
        try await supabase.database.from("friend_connections")
            .update(["status": "accepted"]).eq("id", value: requestId.uuidString).execute()
    }

    func declineFriendRequest(requestId: UUID) async throws {
        try await supabase.database.from("friend_connections")
            .update(["status": "declined"]).eq("id", value: requestId.uuidString).execute()
    }

    func removeFriend(connectionId: UUID) async throws {
        try await supabase.database.from("friend_connections").delete()
            .eq("id", value: connectionId.uuidString).execute()
    }

    func fetchPendingRequests() async throws -> [FriendConnection] {
        let userId = try await supabase.auth.session.user.id
        return try await supabase.database.from("friend_connections").select()
            .eq("addressee_id", value: userId.uuidString)
            .eq("status", value: "pending")
            .order("created_at", ascending: false)
            .execute().value
    }

    func searchUsers(query: String) async throws -> [UserProfile] {
        guard query.count >= 2 else { return [] }
        let userId = try await supabase.auth.session.user.id
        return try await supabase.database.from("user_profiles").select()
            .ilike("username", value: "%\(query)%")
            .neq("id", value: userId.uuidString)
            .limit(20).execute().value
    }

    private func fetchAcceptedFriendIds(for userId: UUID) async throws -> [UUID] {
        let asReq: [FriendConnection] = try await supabase.database.from("friend_connections").select()
            .eq("requester_id", value: userId.uuidString).eq("status", value: "accepted").execute().value
        let asAddr: [FriendConnection] = try await supabase.database.from("friend_connections").select()
            .eq("addressee_id", value: userId.uuidString).eq("status", value: "accepted").execute().value
        return Array(Set(asReq.map(\.addresseeId) + asAddr.map(\.requesterId)))
    }
}
