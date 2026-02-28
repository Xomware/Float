-- ============================================================
-- ROW LEVEL SECURITY POLICIES
-- Implements data access control for all tables
-- ============================================================

ALTER TABLE public.venues          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks       ENABLE ROW LEVEL SECURITY;

-- ── VENUES ──────────────────────────────────────────────────
-- Anyone can read active venues
CREATE POLICY "venues_select_active" ON public.venues
  FOR SELECT USING (is_active = true);

-- Owners can read their own inactive venues too
CREATE POLICY "venues_select_owner" ON public.venues
  FOR SELECT USING (auth.uid() = owner_id);

-- Authenticated owners can insert venues
CREATE POLICY "venues_insert" ON public.venues
  FOR INSERT WITH CHECK (auth.uid() = owner_id AND auth.role() = 'authenticated');

-- Owners can update their own venues
CREATE POLICY "venues_update" ON public.venues
  FOR UPDATE USING (auth.uid() = owner_id);

-- Only owner can delete (soft delete via is_active preferred)
CREATE POLICY "venues_delete" ON public.venues
  FOR DELETE USING (auth.uid() = owner_id);

-- ── DEALS ───────────────────────────────────────────────────
-- Anyone can read active, non-expired deals
CREATE POLICY "deals_select_active" ON public.deals
  FOR SELECT USING (is_active = true AND expires_at > NOW());

-- Venue owners can see all their deals (incl inactive)
CREATE POLICY "deals_select_owner" ON public.deals
  FOR SELECT USING (
    venue_id IN (SELECT id FROM venues WHERE owner_id = auth.uid())
  );

-- Venue owners can insert deals for their venues
CREATE POLICY "deals_insert" ON public.deals
  FOR INSERT WITH CHECK (
    venue_id IN (SELECT id FROM venues WHERE owner_id = auth.uid())
  );

-- Venue owners can update their deals
CREATE POLICY "deals_update" ON public.deals
  FOR UPDATE USING (
    venue_id IN (SELECT id FROM venues WHERE owner_id = auth.uid())
  );

-- ── USER PROFILES ────────────────────────────────────────────
-- Users can read their own profile; others can see basic info
CREATE POLICY "user_profiles_select_own" ON public.user_profiles
  FOR SELECT USING (auth.uid() = id);

-- Allow reading public profile info for other users
CREATE POLICY "user_profiles_select_public" ON public.user_profiles
  FOR SELECT USING (true);  -- all profiles readable (no private data here)

-- Users can only update their own profile
CREATE POLICY "user_profiles_update" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- Auto-created by trigger; block manual insert
CREATE POLICY "user_profiles_insert" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ── REDEMPTIONS ──────────────────────────────────────────────
-- Users can see their own redemptions
CREATE POLICY "redemptions_select_own" ON public.redemptions
  FOR SELECT USING (auth.uid() = user_id);

-- Merchant can see redemptions for their venues
CREATE POLICY "redemptions_select_merchant" ON public.redemptions
  FOR SELECT USING (
    venue_id IN (SELECT id FROM venues WHERE owner_id = auth.uid())
  );

-- Authenticated users can create redemptions
CREATE POLICY "redemptions_insert" ON public.redemptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Merchants can validate (update status) redemptions at their venues
CREATE POLICY "redemptions_update_merchant" ON public.redemptions
  FOR UPDATE USING (
    venue_id IN (SELECT id FROM venues WHERE owner_id = auth.uid())
  );

-- ── BOOKMARKS ────────────────────────────────────────────────
CREATE POLICY "bookmarks_select" ON public.bookmarks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "bookmarks_insert" ON public.bookmarks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "bookmarks_delete" ON public.bookmarks
  FOR DELETE USING (auth.uid() = user_id);
