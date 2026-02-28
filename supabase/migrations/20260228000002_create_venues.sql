-- ============================================================
-- VENUES TABLE
-- Bars, restaurants, lounges, rooftops that push deals
-- ============================================================

CREATE TABLE public.venues (
  id                UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  name              TEXT        NOT NULL,
  slug              TEXT        UNIQUE NOT NULL,
  description       TEXT,
  category          TEXT        NOT NULL CHECK (category IN ('bar','restaurant','lounge','rooftop','club','cafe')),
  address           TEXT        NOT NULL,
  city              TEXT        NOT NULL,
  state             TEXT        NOT NULL CHECK (LENGTH(state) = 2),
  zip               TEXT,
  location          GEOGRAPHY(POINT, 4326) NOT NULL,  -- PostGIS geospatial point
  phone             TEXT,
  website           TEXT,
  instagram         TEXT,
  image_url         TEXT,
  cover_image_url   TEXT,
  rating            DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
  review_count      INT          DEFAULT 0,
  is_active         BOOLEAN      DEFAULT true,
  is_verified       BOOLEAN      DEFAULT false,
  owner_id          UUID         REFERENCES auth.users(id) ON DELETE SET NULL,
  hours             JSONB,        -- {"mon": {"open": "16:00", "close": "02:00"}, ...}
  amenities         TEXT[],       -- ['outdoor_seating','live_music','sports_tv','dj']
  price_range       INT          CHECK (price_range BETWEEN 1 AND 4),  -- $ to $$$$
  created_at        TIMESTAMPTZ  DEFAULT NOW(),
  updated_at        TIMESTAMPTZ  DEFAULT NOW()
);

-- Geospatial index for fast proximity queries
CREATE INDEX venues_location_gist_idx ON venues USING GIST(location);
-- Standard indexes
CREATE INDEX venues_city_idx       ON venues(city);
CREATE INDEX venues_is_active_idx  ON venues(is_active) WHERE is_active = true;
CREATE INDEX venues_owner_idx      ON venues(owner_id);
CREATE INDEX venues_slug_idx       ON venues(slug);
-- Text search index
CREATE INDEX venues_name_trgm_idx  ON venues USING GIN(name gin_trgm_ops);

COMMENT ON TABLE venues IS 'Bars and restaurants that publish deals on Float';
COMMENT ON COLUMN venues.location IS 'PostGIS geography point (WGS84). Use ST_MakePoint(lng, lat)::geography';
COMMENT ON COLUMN venues.hours IS 'JSON: {"mon": {"open": "16:00", "close": "02:00"}, "tue": {...}, ...}';
