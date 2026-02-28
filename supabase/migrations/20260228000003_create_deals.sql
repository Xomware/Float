-- ============================================================
-- DEALS TABLE
-- Time-limited drink/food specials pushed by venues
-- ============================================================

CREATE TABLE public.deals (
  id                UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  venue_id          UUID        NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
  title             TEXT        NOT NULL,
  description       TEXT,
  category          TEXT        NOT NULL CHECK (category IN ('drink','food','combo','event','happy_hour')),
  discount_type     TEXT        NOT NULL CHECK (discount_type IN ('percentage','fixed','bogo','free','special')),
  discount_value    DECIMAL(10,2),             -- 25 (for 25% off), or 5.00 (for $5 off)
  original_price    DECIMAL(10,2),
  deal_price        DECIMAL(10,2),
  image_url         TEXT,
  starts_at         TIMESTAMPTZ NOT NULL,
  expires_at        TIMESTAMPTZ NOT NULL,
  is_active         BOOLEAN     DEFAULT true,
  is_featured       BOOLEAN     DEFAULT false,
  max_redemptions   INT,                        -- NULL = unlimited
  redemption_count  INT         DEFAULT 0,
  terms             TEXT,
  tags              TEXT[],                     -- ['margaritas','tequila','2-for-1']
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT deals_dates_valid CHECK (expires_at > starts_at),
  CONSTRAINT deals_price_valid CHECK (
    (discount_type = 'percentage' AND discount_value BETWEEN 1 AND 100) OR
    (discount_type != 'percentage')
  )
);

CREATE INDEX deals_venue_idx      ON deals(venue_id);
CREATE INDEX deals_active_idx     ON deals(is_active, expires_at) WHERE is_active = true;
CREATE INDEX deals_featured_idx   ON deals(is_featured)           WHERE is_featured = true;
CREATE INDEX deals_category_idx   ON deals(category);
CREATE INDEX deals_starts_at_idx  ON deals(starts_at);
CREATE INDEX deals_expires_at_idx ON deals(expires_at);
-- Full-text search
CREATE INDEX deals_title_trgm_idx ON deals USING GIN(title gin_trgm_ops);
CREATE INDEX deals_tags_idx       ON deals USING GIN(tags);

COMMENT ON TABLE deals IS 'Time-limited happy hour specials and promotions';
COMMENT ON COLUMN deals.discount_type IS 'percentage | fixed | bogo | free | special';
