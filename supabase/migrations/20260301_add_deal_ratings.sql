-- Deal Ratings & Reviews
-- Sprint 7: Post-redemption rating system

CREATE TABLE deal_ratings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES auth.users(id),
    deal_id uuid REFERENCES deals(id),
    rating integer CHECK (rating >= 1 AND rating <= 5),
    review text CHECK (char_length(review) <= 200),
    created_at timestamptz DEFAULT now(),
    UNIQUE(user_id, deal_id)
);

-- Enable RLS
ALTER TABLE deal_ratings ENABLE ROW LEVEL SECURITY;

-- Users can read all ratings
CREATE POLICY "Anyone can read ratings"
    ON deal_ratings FOR SELECT
    USING (true);

-- Users can insert their own ratings
CREATE POLICY "Users can insert own ratings"
    ON deal_ratings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own ratings
CREATE POLICY "Users can update own ratings"
    ON deal_ratings FOR UPDATE
    USING (auth.uid() = user_id);

-- Summary view for average ratings
CREATE OR REPLACE VIEW deal_rating_summary AS
    SELECT
        deal_id,
        ROUND(AVG(rating)::numeric, 1) as avg_rating,
        COUNT(*) as review_count
    FROM deal_ratings
    GROUP BY deal_id;
