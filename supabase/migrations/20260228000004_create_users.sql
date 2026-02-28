-- ============================================================
-- USER PROFILES TABLE
-- Extended profile data (auth.users has base auth fields)
-- ============================================================

CREATE TABLE public.user_profiles (
  id                  UUID         PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username            TEXT         UNIQUE,
  display_name        TEXT,
  avatar_url          TEXT,
  bio                 TEXT,
  location_city       TEXT,
  location_state      TEXT,
  total_redemptions   INT          DEFAULT 0,
  total_savings       DECIMAL(10,2) DEFAULT 0.00,
  favorite_categories TEXT[]       DEFAULT '{}',
  notification_prefs  JSONB        DEFAULT '{"deals_nearby": true, "expiring_soon": true, "new_venues": false, "weekly_roundup": true}'::jsonb,
  apns_token          TEXT,                      -- device push token
  is_merchant         BOOLEAN      DEFAULT false, -- can they publish deals?
  created_at          TIMESTAMPTZ  DEFAULT NOW(),
  updated_at          TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX user_profiles_username_idx ON user_profiles(username);
CREATE INDEX user_profiles_merchant_idx ON user_profiles(is_merchant) WHERE is_merchant = true;

-- Auto-create user profile on auth.users insert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, display_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

COMMENT ON TABLE user_profiles IS 'Extended user profiles — linked 1:1 with auth.users';
