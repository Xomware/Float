-- ============================================================
-- PUSH NOTIFICATION TRIGGERS
-- Wires Postgres events to Float edge functions via pg_net.
-- Requires: pg_net extension (enabled by Supabase by default)
-- ============================================================

-- Enable pg_net for HTTP calls from database triggers
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ── Scheduled cron for expiring deals ────────────────────────
-- Requires pg_cron extension (enable in Supabase Dashboard → Extensions)
-- Runs every 15 minutes to catch deals expiring in next 30 min window.
--
-- Uncomment and set your project URL + service key before running:
--
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- SELECT cron.schedule(
--   'float-notify-expiring-deals',
--   '*/15 * * * *',
--   $$
--     SELECT net.http_post(
--       url     := '<YOUR_SUPABASE_URL>/functions/v1/notify-expiring-deals',
--       headers := jsonb_build_object(
--         'Authorization', 'Bearer <YOUR_SERVICE_ROLE_KEY>',
--         'Content-Type', 'application/json'
--       ),
--       body    := '{}'::jsonb
--     ) AS request_id;
--   $$
-- );

-- ── Trigger: notify on new deal (favorited venue) ─────────────
-- When a new active deal is created, call notify-favorites edge function.

CREATE OR REPLACE FUNCTION public.notify_new_deal()
RETURNS TRIGGER AS $$
DECLARE
  supabase_url  TEXT := current_setting('app.supabase_url',  true);
  service_key   TEXT := current_setting('app.service_role_key', true);
BEGIN
  -- Only fire for active deals that are starting now or already started
  IF NEW.is_active = true AND NEW.starts_at <= NOW() THEN
    PERFORM net.http_post(
      url     := supabase_url || '/functions/v1/notify-favorites',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || service_key,
        'Content-Type',  'application/json'
      ),
      body    := jsonb_build_object('deal_id', NEW.id)
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach trigger to deals table (INSERT only — updates handled separately)
CREATE TRIGGER on_new_deal_created
  AFTER INSERT ON public.deals
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_new_deal();

-- ── Configure app settings (run once after migration) ─────────
-- Set these via Supabase Dashboard → Database → Settings, or:
--
-- ALTER DATABASE postgres
--   SET app.supabase_url = 'https://<project>.supabase.co';
-- ALTER DATABASE postgres
--   SET app.service_role_key = '<your-service-role-key>';
--
-- Or use pg_tle / vault for secret management.

COMMENT ON FUNCTION public.notify_new_deal() IS
  'Fires net.http_post to notify-favorites edge function when a new active deal is created';

-- ── Index: speed up expiry window queries ────────────────────
-- Helps the notify-expiring-deals function find deals efficiently
CREATE INDEX IF NOT EXISTS deals_expiry_window_idx
  ON deals(expires_at, is_active)
  WHERE is_active = true;
