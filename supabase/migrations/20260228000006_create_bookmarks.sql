-- ============================================================
-- BOOKMARKS TABLE
-- Users can bookmark deals and venues
-- ============================================================

CREATE TABLE public.bookmarks (
  id          UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID         NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  deal_id     UUID         REFERENCES deals(id) ON DELETE CASCADE,
  venue_id    UUID         REFERENCES venues(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ  DEFAULT NOW(),
  
  CONSTRAINT bookmarks_target_check CHECK (
    (deal_id IS NOT NULL AND venue_id IS NULL) OR
    (deal_id IS NULL AND venue_id IS NOT NULL)
  ),
  UNIQUE(user_id, deal_id),
  UNIQUE(user_id, venue_id)
);

CREATE INDEX bookmarks_user_idx  ON bookmarks(user_id);
CREATE INDEX bookmarks_deal_idx  ON bookmarks(deal_id) WHERE deal_id IS NOT NULL;
CREATE INDEX bookmarks_venue_idx ON bookmarks(venue_id) WHERE venue_id IS NOT NULL;

COMMENT ON TABLE bookmarks IS 'Users can save deals and venues for later';
