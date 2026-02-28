-- ============================================================
-- NOTIFICATION LOG TABLE
-- Records all push notifications sent to users.
-- Powers in-app notification history / inbox.
-- ============================================================

CREATE TYPE notification_type AS ENUM (
  'favorited_venue_new_deal',
  'geofence_nearby_deal',
  'deal_expiring_soon',
  'system_announcement'
);

CREATE TABLE public.notification_log (
  id                UUID               PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID               NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notification_type notification_type  NOT NULL,
  title             TEXT               NOT NULL,
  body              TEXT               NOT NULL,
  deal_id           UUID               REFERENCES deals(id) ON DELETE SET NULL,
  venue_id          UUID               REFERENCES venues(id) ON DELETE SET NULL,
  is_read           BOOLEAN            NOT NULL DEFAULT false,
  sent_at           TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
  read_at           TIMESTAMPTZ,

  -- Metadata stored for analytics / retry
  device_token      TEXT,
  apns_status       TEXT,              -- 'sent', 'failed', 'invalid_token', 'skipped'
  error_message     TEXT
);

-- Indexes
CREATE INDEX notification_log_user_idx      ON notification_log(user_id, sent_at DESC);
CREATE INDEX notification_log_unread_idx    ON notification_log(user_id, is_read) WHERE is_read = false;
CREATE INDEX notification_log_deal_idx      ON notification_log(deal_id)  WHERE deal_id IS NOT NULL;
CREATE INDEX notification_log_venue_idx     ON notification_log(venue_id) WHERE venue_id IS NOT NULL;
CREATE INDEX notification_log_type_idx      ON notification_log(notification_type);
CREATE INDEX notification_log_sent_at_idx   ON notification_log(sent_at DESC);

-- Auto-set read_at timestamp
CREATE OR REPLACE FUNCTION public.set_notification_read_at()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_read = true AND OLD.is_read = false THEN
    NEW.read_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notification_log_read_at
  BEFORE UPDATE OF is_read ON notification_log
  FOR EACH ROW EXECUTE FUNCTION public.set_notification_read_at();

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE notification_log ENABLE ROW LEVEL SECURITY;

-- Users can only read and update their own notifications
CREATE POLICY "notification_log_owner_select" ON notification_log
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "notification_log_owner_update" ON notification_log
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Service role can insert and read all (used by edge functions)
CREATE POLICY "notification_log_service_all" ON notification_log
  FOR ALL USING (auth.role() = 'service_role');

-- ============================================================
-- DATABASE FUNCTION: unread notification count
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_unread_notification_count(p_user_id UUID)
RETURNS INT AS $$
  SELECT COUNT(*)::INT
  FROM notification_log
  WHERE user_id = p_user_id AND is_read = false;
$$ LANGUAGE SQL STABLE SECURITY DEFINER;

COMMENT ON TABLE notification_log IS 'Audit log of all push notifications sent to users; powers in-app notification inbox';
COMMENT ON COLUMN notification_log.apns_status IS 'APNs response status: sent | failed | invalid_token | skipped';
