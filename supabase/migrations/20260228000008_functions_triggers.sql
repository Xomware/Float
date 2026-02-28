-- ============================================================
-- DATABASE FUNCTIONS & TRIGGERS
-- Geo queries, auto-timestamps, analytics
-- ============================================================

-- ── Auto-update updated_at timestamp ────────────────────────
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_venues_updated_at    BEFORE UPDATE ON venues    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER set_deals_updated_at     BEFORE UPDATE ON deals     FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER set_profiles_updated_at  BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── Geo: Get active deals within radius ──────────────────────
CREATE OR REPLACE FUNCTION public.get_deals_nearby(
  user_lat    FLOAT,
  user_lng    FLOAT,
  radius_m    INT     DEFAULT 5000,
  deal_cat    TEXT    DEFAULT NULL,
  result_limit INT    DEFAULT 50
)
RETURNS TABLE (
  deal_id         UUID,
  deal_title      TEXT,
  deal_description TEXT,
  deal_category   TEXT,
  discount_type   TEXT,
  discount_value  DECIMAL,
  deal_price      DECIMAL,
  expires_at      TIMESTAMPTZ,
  is_featured     BOOLEAN,
  redemption_count INT,
  venue_id        UUID,
  venue_name      TEXT,
  venue_slug      TEXT,
  venue_category  TEXT,
  venue_address   TEXT,
  venue_city      TEXT,
  venue_rating    DECIMAL,
  venue_image_url TEXT,
  distance_m      FLOAT,
  venue_lat       FLOAT,
  venue_lng       FLOAT
) AS $$
  SELECT
    d.id,
    d.title,
    d.description,
    d.category,
    d.discount_type,
    d.discount_value,
    d.deal_price,
    d.expires_at,
    d.is_featured,
    d.redemption_count,
    v.id,
    v.name,
    v.slug,
    v.category,
    v.address,
    v.city,
    v.rating,
    v.image_url,
    ST_Distance(
      v.location::geography,
      ST_MakePoint(user_lng, user_lat)::geography
    ) AS distance_m,
    ST_Y(v.location::geometry) AS lat,
    ST_X(v.location::geometry) AS lng
  FROM deals d
  JOIN venues v ON v.id = d.venue_id
  WHERE
    v.is_active = true
    AND d.is_active = true
    AND d.starts_at <= NOW()
    AND d.expires_at > NOW()
    AND (d.max_redemptions IS NULL OR d.redemption_count < d.max_redemptions)
    AND ST_DWithin(
      v.location::geography,
      ST_MakePoint(user_lng, user_lat)::geography,
      radius_m
    )
    AND (deal_cat IS NULL OR d.category = deal_cat)
  ORDER BY
    d.is_featured DESC,
    distance_m ASC,
    d.expires_at ASC
  LIMIT result_limit;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ── Expire stale deals (called by cron edge function) ────────
CREATE OR REPLACE FUNCTION public.expire_stale_deals()
RETURNS INT AS $$
DECLARE
  expired_count INT;
BEGIN
  UPDATE deals
  SET is_active = false
  WHERE is_active = true
    AND expires_at < NOW();
  
  GET DIAGNOSTICS expired_count = ROW_COUNT;
  
  RAISE NOTICE 'Expired % deals at %', expired_count, NOW();
  RETURN expired_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── Venue deal stats view ────────────────────────────────────
CREATE OR REPLACE VIEW public.venue_deal_stats AS
SELECT
  v.id AS venue_id,
  v.name AS venue_name,
  COUNT(d.id) AS total_deals,
  COUNT(d.id) FILTER (WHERE d.is_active AND d.expires_at > NOW()) AS active_deals,
  COALESCE(SUM(d.redemption_count), 0) AS total_redemptions,
  MAX(d.created_at) AS last_deal_at
FROM venues v
LEFT JOIN deals d ON d.venue_id = v.id
GROUP BY v.id, v.name;

-- ── Search venues by name (fuzzy) ────────────────────────────
CREATE OR REPLACE FUNCTION public.search_venues(
  search_query TEXT,
  search_city  TEXT DEFAULT NULL,
  result_limit INT  DEFAULT 20
)
RETURNS TABLE (
  id       UUID,
  name     TEXT,
  slug     TEXT,
  category TEXT,
  city     TEXT,
  rating   DECIMAL,
  similarity FLOAT
) AS $$
  SELECT
    id, name, slug, category, city, rating,
    similarity(name, search_query) AS sim
  FROM venues
  WHERE
    is_active = true
    AND name % search_query   -- trigram similarity match
    AND (search_city IS NULL OR city ILIKE search_city)
  ORDER BY sim DESC, rating DESC
  LIMIT result_limit;
$$ LANGUAGE sql STABLE;
