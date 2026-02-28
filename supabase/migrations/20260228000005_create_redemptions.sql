-- ============================================================
-- REDEMPTIONS TABLE
-- Tracks when users redeem a deal (QR code flow)
-- ============================================================

CREATE TABLE public.redemptions (
  id              UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID         NOT NULL REFERENCES auth.users(id),
  deal_id         UUID         NOT NULL REFERENCES deals(id),
  venue_id        UUID         NOT NULL REFERENCES venues(id),
  qr_token        TEXT         UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'),
  status          TEXT         DEFAULT 'pending' CHECK (status IN ('pending','validated','expired','cancelled')),
  redeemed_at     TIMESTAMPTZ,
  validated_by    UUID         REFERENCES auth.users(id),  -- merchant staff who scanned
  validated_at    TIMESTAMPTZ,
  savings_amount  DECIMAL(10,2),
  notes           TEXT,
  created_at      TIMESTAMPTZ  DEFAULT NOW(),
  
  UNIQUE(user_id, deal_id)  -- one redemption per user per deal
);

CREATE INDEX redemptions_user_idx   ON redemptions(user_id);
CREATE INDEX redemptions_deal_idx   ON redemptions(deal_id);
CREATE INDEX redemptions_venue_idx  ON redemptions(venue_id);
CREATE INDEX redemptions_status_idx ON redemptions(status);
CREATE INDEX redemptions_token_idx  ON redemptions(qr_token);

-- When a redemption is validated, update deal count + user stats
CREATE OR REPLACE FUNCTION public.handle_redemption_validated()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'validated' AND OLD.status = 'pending' THEN
    -- Increment deal redemption count
    UPDATE deals SET redemption_count = redemption_count + 1 WHERE id = NEW.deal_id;
    
    -- Update user stats
    UPDATE user_profiles 
    SET 
      total_redemptions = total_redemptions + 1,
      total_savings = total_savings + COALESCE(NEW.savings_amount, 0)
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_redemption_validated
  AFTER UPDATE ON redemptions
  FOR EACH ROW EXECUTE FUNCTION public.handle_redemption_validated();

COMMENT ON TABLE redemptions IS 'Deal redemptions — generated when user taps Redeem, validated when merchant scans QR';
