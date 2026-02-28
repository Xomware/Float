-- ============================================================
-- SEED DATA — 10 NYC Venues + 20 Active Deals
-- For development and staging environments
-- ============================================================

-- Temporary: disable RLS for seeding
SET session_replication_role = replica;

-- ── NYC VENUES ───────────────────────────────────────────────

INSERT INTO venues (id, name, slug, description, category, address, city, state, zip, location, phone, instagram, rating, review_count, is_active, is_verified, hours, amenities, price_range) VALUES

-- 1. Employees Only
('11111111-1111-1111-1111-111111111111',
 'Employees Only', 'employees-only',
 'Legendary speakeasy with Prohibition-era craft cocktails in the West Village.',
 'bar', '510 Hudson St', 'New York', 'NY', '10014',
 ST_MakePoint(-74.0051, 40.7332)::geography,
 '+1-212-242-3021', '@employeesonlynyc', 4.7, 3241, true, true,
 '{"mon":{"open":"18:00","close":"03:30"},"tue":{"open":"18:00","close":"03:30"},"wed":{"open":"18:00","close":"03:30"},"thu":{"open":"18:00","close":"03:30"},"fri":{"open":"18:00","close":"03:30"},"sat":{"open":"18:00","close":"03:30"},"sun":{"open":"18:00","close":"03:30"}}',
 ARRAY['craft_cocktails','full_kitchen','live_music'], 3),

-- 2. Death & Co
('22222222-2222-2222-2222-222222222222',
 'Death & Co', 'death-and-co',
 'Award-winning cocktail bar in the East Village. James Beard Award winner.',
 'bar', '433 E 6th St', 'New York', 'NY', '10009',
 ST_MakePoint(-73.9837, 40.7263)::geography,
 '+1-212-388-0882', '@deathandcompany', 4.8, 5102, true, true,
 '{"mon":{"open":"18:00","close":"02:00"},"tue":{"open":"18:00","close":"02:00"},"wed":{"open":"18:00","close":"02:00"},"thu":{"open":"18:00","close":"02:00"},"fri":{"open":"17:00","close":"02:00"},"sat":{"open":"17:00","close":"02:00"},"sun":{"open":"17:00","close":"02:00"}}',
 ARRAY['craft_cocktails','no_standing','reservations'], 3),

-- 3. Amor y Amargo
('33333333-3333-3333-3333-333333333333',
 'Amor y Amargo', 'amor-y-amargo',
 'Bitters-focused cocktail bar. Tiny, intimate, and spectacular.',
 'bar', '443 E 6th St', 'New York', 'NY', '10009',
 ST_MakePoint(-73.9838, 40.7262)::geography,
 '+1-212-614-6818', '@amoryamargo', 4.6, 1876, true, true,
 '{"mon":{"open":"17:00","close":"00:00"},"tue":{"open":"17:00","close":"00:00"},"wed":{"open":"17:00","close":"00:00"},"thu":{"open":"17:00","close":"01:00"},"fri":{"open":"17:00","close":"02:00"},"sat":{"open":"17:00","close":"02:00"},"sun":{"open":"17:00","close":"23:00"}}',
 ARRAY['craft_cocktails','intimate'], 2),

-- 4. The Long Island Bar
('44444444-4444-4444-4444-444444444444',
 'The Long Island Bar', 'long-island-bar',
 'Classic American bar in a restored 1950s diner space in Brooklyn.',
 'bar', '110 Atlantic Ave', 'Brooklyn', 'NY', '11201',
 ST_MakePoint(-73.9953, 40.6896)::geography,
 '+1-718-625-8908', '@longislandbar', 4.5, 2087, true, true,
 '{"mon":{"open":"17:00","close":"02:00"},"tue":{"open":"17:00","close":"02:00"},"wed":{"open":"17:00","close":"02:00"},"thu":{"open":"17:00","close":"02:00"},"fri":{"open":"15:00","close":"04:00"},"sat":{"open":"13:00","close":"04:00"},"sun":{"open":"13:00","close":"02:00"}}',
 ARRAY['classic_cocktails','beer_on_tap','kitchen'], 2),

-- 5. Attaboy
('55555555-5555-5555-5555-555555555555',
 'Attaboy', 'attaboy',
 'No-menu bar on the Lower East Side. Tell them what you like, they make you something perfect.',
 'bar', '134 Eldridge St', 'New York', 'NY', '10002',
 ST_MakePoint(-73.9921, 40.7174)::geography,
 NULL, '@attaboynyc', 4.7, 4388, true, true,
 '{"mon":{"open":"18:00","close":"04:00"},"tue":{"open":"18:00","close":"04:00"},"wed":{"open":"18:00","close":"04:00"},"thu":{"open":"18:00","close":"04:00"},"fri":{"open":"18:00","close":"04:00"},"sat":{"open":"18:00","close":"04:00"},"sun":{"open":"18:00","close":"04:00"}}',
 ARRAY['craft_cocktails','no_menu','walk_in'], 3),

-- 6. The Dead Rabbit
('66666666-6666-6666-6666-666666666666',
 'The Dead Rabbit', 'dead-rabbit',
 'World-famous Irish bar & cocktail saloon in the Financial District.',
 'bar', '30 Water St', 'New York', 'NY', '10004',
 ST_MakePoint(-74.0131, 40.7033)::geography,
 '+1-646-422-7906', '@deadrabbitnyc', 4.6, 7211, true, true,
 '{"mon":{"open":"11:00","close":"02:00"},"tue":{"open":"11:00","close":"02:00"},"wed":{"open":"11:00","close":"02:00"},"thu":{"open":"11:00","close":"02:00"},"fri":{"open":"11:00","close":"03:00"},"sat":{"open":"11:00","close":"03:00"},"sun":{"open":"11:00","close":"02:00"}}',
 ARRAY['craft_cocktails','irish_whiskey','pub_food','live_music'], 3),

-- 7. Extra Fancy
('77777777-7777-7777-7777-777777777777',
 'Extra Fancy', 'extra-fancy',
 'Relaxed Williamsburg bar with draft cocktails, beer, oysters, and good vibes.',
 'bar', '302 Metropolitan Ave', 'Brooklyn', 'NY', '11211',
 ST_MakePoint(-73.9548, 40.7143)::geography,
 '+1-347-422-0939', '@extrafancybk', 4.4, 1543, true, true,
 '{"mon":{"open":"16:00","close":"02:00"},"tue":{"open":"16:00","close":"02:00"},"wed":{"open":"16:00","close":"02:00"},"thu":{"open":"16:00","close":"02:00"},"fri":{"open":"14:00","close":"04:00"},"sat":{"open":"12:00","close":"04:00"},"sun":{"open":"12:00","close":"02:00"}}',
 ARRAY['oysters','draft_cocktails','outdoor_seating'], 2),

-- 8. The NoMad Bar
('88888888-8888-8888-8888-888888888888',
 'The NoMad Bar', 'nomad-bar',
 'Sophisticated hotel bar in the NoMad neighborhood with an exceptional cocktail program.',
 'lounge', '10 W 28th St', 'New York', 'NY', '10001',
 ST_MakePoint(-73.9916, 40.7453)::geography,
 '+1-347-472-5660', '@thenomadhotel', 4.5, 2931, true, true,
 '{"mon":{"open":"17:00","close":"01:00"},"tue":{"open":"17:00","close":"01:00"},"wed":{"open":"17:00","close":"01:00"},"thu":{"open":"17:00","close":"01:00"},"fri":{"open":"17:00","close":"02:00"},"sat":{"open":"17:00","close":"02:00"},"sun":{"open":"17:00","close":"00:00"}}',
 ARRAY['hotel_bar','craft_cocktails','reservations','kitchen'], 4),

-- 9. Le Bain
('99999999-9999-9999-9999-999999999999',
 'Le Bain', 'le-bain',
 'Rooftop bar and club atop The Standard Hotel in the Meatpacking District.',
 'rooftop', '848 Washington St', 'New York', 'NY', '10014',
 ST_MakePoint(-74.0078, 40.7406)::geography,
 '+1-212-645-4646', '@lebainnyc', 4.3, 4102, true, true,
 '{"thu":{"open":"22:00","close":"04:00"},"fri":{"open":"22:00","close":"04:00"},"sat":{"open":"22:00","close":"04:00"}}',
 ARRAY['rooftop','club','views','dancing'], 4),

-- 10. Bar Goto
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 'Bar Goto', 'bar-goto',
 'Intimate LES bar by Kenta Goto. Japanese-influenced craft cocktails and Japanese bar snacks.',
 'bar', '245 Eldridge St', 'New York', 'NY', '10002',
 ST_MakePoint(-73.9891, 40.7223)::geography,
 '+1-212-475-4411', '@bargoto', 4.7, 2108, true, true,
 '{"tue":{"open":"17:00","close":"01:00"},"wed":{"open":"17:00","close":"01:00"},"thu":{"open":"17:00","close":"01:00"},"fri":{"open":"17:00","close":"02:00"},"sat":{"open":"17:00","close":"02:00"},"sun":{"open":"17:00","close":"00:00"}}',
 ARRAY['japanese_cocktails','sake','bar_snacks','intimate'], 3);

-- ── ACTIVE DEALS ─────────────────────────────────────────────

INSERT INTO deals (id, venue_id, title, description, category, discount_type, discount_value, original_price, deal_price, starts_at, expires_at, is_active, is_featured, tags) VALUES

-- Employees Only deals
('d1111111-1111-1111-1111-111111111111',
 '11111111-1111-1111-1111-111111111111',
 'Happy Hour: $3 Off All Cocktails', 'All signature cocktails $3 off during our happy hour window.',
 'drink', 'fixed', 3.00, 18.00, 15.00,
 NOW(), NOW() + INTERVAL '4 hours', true, true,
 ARRAY['cocktails','happy_hour','west_village']),

('d2222222-2222-2222-2222-222222222222',
 '11111111-1111-1111-1111-111111111111',
 'Bar Snack Combo: Cocktail + Oysters', 'Any cocktail + 6 oysters for $28 (save $12).',
 'combo', 'fixed', 12.00, 40.00, 28.00,
 NOW(), NOW() + INTERVAL '3 hours', true, false,
 ARRAY['oysters','cocktails','combo']),

-- Death & Co deals
('d3333333-3333-3333-3333-333333333333',
 '22222222-2222-2222-2222-222222222222',
 'Opening Special: 20% Off First Round', 'First cocktail of the night 20% off, any spirit.',
 'drink', 'percentage', 20.00, NULL, NULL,
 NOW(), NOW() + INTERVAL '2 hours', true, true,
 ARRAY['cocktails','opening_special','east_village']),

-- Amor y Amargo deals
('d4444444-4444-4444-4444-444444444444',
 '33333333-3333-3333-3333-333333333333',
 'Bitters Flight for $12', 'Curated flight of 5 amaro samples — normally $20.',
 'drink', 'fixed', 8.00, 20.00, 12.00,
 NOW(), NOW() + INTERVAL '5 hours', true, false,
 ARRAY['amaro','bitters','tasting_flight']),

-- Long Island Bar deals
('d5555555-5555-5555-5555-555555555555',
 '44444444-4444-4444-4444-444444444444',
 'BOGO Drafts 4-6pm', 'Buy one draft beer, get one free. All handles included.',
 'drink', 'bogo', NULL, NULL, NULL,
 NOW(), NOW() + INTERVAL '1 hours', true, true,
 ARRAY['beer','bogo','happy_hour','brooklyn']),

('d6666666-6666-6666-6666-666666666666',
 '44444444-4444-4444-4444-444444444444',
 'Burger + Beer $16', 'Classic burger and any draft for $16 — a $24 value.',
 'combo', 'fixed', 8.00, 24.00, 16.00,
 NOW(), NOW() + INTERVAL '6 hours', true, false,
 ARRAY['burger','beer','combo','food']),

-- Attaboy deals
('d7777777-7777-7777-7777-777777777777',
 '55555555-5555-5555-5555-555555555555',
 'Bartender''s Choice: $15 Custom Cocktail', 'Tell us your mood, we make it. Usually $18+.',
 'drink', 'fixed', 3.00, 18.00, 15.00,
 NOW(), NOW() + INTERVAL '3 hours', true, true,
 ARRAY['custom_cocktail','les','no_menu']),

-- Dead Rabbit deals
('d8888888-8888-8888-8888-888888888888',
 '66666666-6666-6666-6666-666666666666',
 'Irish Whiskey Flight $18', 'Three-pour Irish whiskey flight with tasting notes. $30 value.',
 'drink', 'fixed', 12.00, 30.00, 18.00,
 NOW(), NOW() + INTERVAL '4 hours', true, false,
 ARRAY['whiskey','irish','flight','financial_district']),

('d9999999-9999-9999-9999-999999999999',
 '66666666-6666-6666-6666-666666666666',
 'Lunch Special: Pub Food + Pint $14', 'Fish & chips or shepherd''s pie + any pint for $14.',
 'combo', 'special', NULL, NULL, 14.00,
 NOW(), NOW() + INTERVAL '2 hours', true, true,
 ARRAY['pub_food','beer','lunch','combo']),

-- Extra Fancy deals
('daaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 '77777777-7777-7777-7777-777777777777',
 '6 Oysters + Cocktail $22', 'Shucked-to-order oysters and a draft cocktail for $22.',
 'combo', 'special', NULL, NULL, 22.00,
 NOW(), NOW() + INTERVAL '5 hours', true, true,
 ARRAY['oysters','cocktails','williamsburg','combo']),

-- NoMad Bar deals
('dbbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
 '88888888-8888-8888-8888-888888888888',
 'Hotel Bar Happy Hour 5-7pm', 'All cocktails 25% off during hotel bar happy hour.',
 'drink', 'percentage', 25.00, NULL, NULL,
 NOW(), NOW() + INTERVAL '2 hours', true, true,
 ARRAY['hotel_bar','happy_hour','nomad','cocktails']),

-- Bar Goto deals
('dcccccccc-cccc-cccc-cccc-cccccccccc12',
 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 'Sake Flight + Okonomiyaki $24', 'Three-pour sake flight paired with okonomiyaki (Japanese pancake).',
 'combo', 'special', NULL, NULL, 24.00,
 NOW(), NOW() + INTERVAL '3 hours', true, true,
 ARRAY['sake','japanese','okonomiyaki','les']);

-- Re-enable RLS
SET session_replication_role = DEFAULT;

-- Verify seed
DO $$
DECLARE
  v_count INT; d_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count FROM venues;
  SELECT COUNT(*) INTO d_count FROM deals;
  RAISE NOTICE 'Seeded: % venues, % deals', v_count, d_count;
END $$;
