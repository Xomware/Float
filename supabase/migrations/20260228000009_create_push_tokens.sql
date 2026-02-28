-- ============================================================
-- PUSH TOKENS TABLE
-- Stores APNs device tokens for push notification delivery.
-- Supports multiple devices per user; old tokens are deactivated
-- on sign-out rather than deleted (for audit purposes).
-- ============================================================

CREATE TABLE public.push_tokens (
  id            UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID          NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  device_token  TEXT          NOT NULL,
  platform      TEXT          NOT NULL DEFAULT 'ios' CHECK (platform IN ('ios', 'android', 'web')),
  app_version   TEXT,
  is_active     BOOLEAN       NOT NULL DEFAULT true,
  last_used_at  TIMESTAMPTZ   DEFAULT NOW(),
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  -- A user can have one active token per unique device token string
  UNIQUE (user_id, device_token)
);

-- Indexes
CREATE INDEX push_tokens_user_idx      ON push_tokens(user_id);
CREATE INDEX push_tokens_active_idx    ON push_tokens(user_id, is_active) WHERE is_active = true;
CREATE INDEX push_tokens_platform_idx  ON push_tokens(platform);

-- Auto-update updated_at
CREATE TRIGGER push_tokens_updated_at
  BEFORE UPDATE ON push_tokens
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- Users can only see and manage their own tokens
CREATE POLICY "push_tokens_owner_select" ON push_tokens
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "push_tokens_owner_insert" ON push_tokens
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "push_tokens_owner_update" ON push_tokens
  FOR UPDATE USING (auth.uid() = user_id);

-- Service role can read all tokens (for send-notification edge function)
CREATE POLICY "push_tokens_service_all" ON push_tokens
  FOR ALL USING (auth.role() = 'service_role');

COMMENT ON TABLE push_tokens IS 'APNs/FCM device tokens for push notification delivery';
COMMENT ON COLUMN push_tokens.device_token IS 'Hex-encoded APNs device token or FCM registration token';
COMMENT ON COLUMN push_tokens.is_active IS 'Set to false on user sign-out or when APNs returns InvalidToken';
