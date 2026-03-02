-- Social features: friend connections and activity likes
-- Sprint 7: Friend Activity Feed (#65)

ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS activity_visibility text DEFAULT 'friends' CHECK (activity_visibility IN ('public', 'friends', 'private'));

CREATE TABLE friend_connections (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    addressee_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    created_at timestamptz DEFAULT now(),
    UNIQUE(requester_id, addressee_id)
);

CREATE INDEX idx_friend_connections_requester ON friend_connections(requester_id);
CREATE INDEX idx_friend_connections_addressee ON friend_connections(addressee_id);
CREATE INDEX idx_friend_connections_status ON friend_connections(status);

CREATE TABLE activity_likes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    redemption_id uuid REFERENCES redemptions(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    UNIQUE(user_id, redemption_id)
);

CREATE INDEX idx_activity_likes_redemption ON activity_likes(redemption_id);

ALTER TABLE friend_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own connections" ON friend_connections
    FOR SELECT USING (auth.uid() = requester_id OR auth.uid() = addressee_id);
CREATE POLICY "Users can send friend requests" ON friend_connections
    FOR INSERT WITH CHECK (auth.uid() = requester_id);
CREATE POLICY "Users can respond to friend requests" ON friend_connections
    FOR UPDATE USING (auth.uid() = addressee_id);
CREATE POLICY "Users can remove connections" ON friend_connections
    FOR DELETE USING (auth.uid() = requester_id OR auth.uid() = addressee_id);

CREATE POLICY "Users can view all likes" ON activity_likes
    FOR SELECT USING (true);
CREATE POLICY "Users can like activities" ON activity_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike activities" ON activity_likes
    FOR DELETE USING (auth.uid() = user_id);
