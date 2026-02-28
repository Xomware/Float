-- ============================================================
-- SEED DATA — 50 Nashville Venues + 200 Active Deals
-- Broadway, Midtown, East Nashville bars, restaurants, nightclubs
-- ============================================================

SET session_replication_role = replica;

-- ── 50 NASHVILLE VENUES ──────────────────────────────────────

INSERT INTO venues (id, name, slug, description, category, address, city, state, zip, location, phone, instagram, rating, review_count, is_active, is_verified, hours, amenities, price_range) VALUES

-- BROADWAY HONKY TONKS & BARS (10 venues)
('10000000-0000-0000-0000-000000000001',
 'The Honky Tonk Central', 'honky-tonk-central',
 'Three-story honky tonk on Broadway with live country music, line dancing, and Nashville vibes.',
 'bar', '118 2nd Ave S', 'Nashville', 'TN', '37201',
 ST_MakePoint(-86.7747, 36.1627)::geography,
 '+1-615-742-2697', '@honkytonkcentral', 4.6, 2841, true, true,
 '{"mon":{"open":"11:00","close":"03:00"},"tue":{"open":"11:00","close":"03:00"},"wed":{"open":"11:00","close":"03:00"},"thu":{"open":"11:00","close":"03:00"},"fri":{"open":"10:00","close":"04:00"},"sat":{"open":"10:00","close":"04:00"},"sun":{"open":"11:00","close":"02:00"}}',
 ARRAY['live_music','line_dancing','country','full_kitchen'], 2),

('10000000-0000-0000-0000-000000000002',
 'Luke''s 32 Bridge Burn', 'lukes-32-bridge',
 'Luke Bryan''s flagship Nashville bar with craft cocktails and live entertainment.',
 'bar', '110 Broadway', 'Nashville', 'TN', '37201',
 ST_MakePoint(-86.7768, 36.1626)::geography,
 '+1-615-726-3700', '@lukes32bridge', 4.5, 1923, true, true,
 '{"mon":{"open":"11:00","close":"03:00"},"tue":{"open":"11:00","close":"03:00"},"wed":{"open":"11:00","close":"03:00"},"thu":{"open":"11:00","close":"03:00"},"fri":{"open":"10:00","close":"04:00"},"sat":{"open":"10:00","close":"04:00"},"sun":{"open":"11:00","close":"02:00"}}',
 ARRAY['live_music','craft_cocktails','country','rooftop'], 3),

('10000000-0000-0000-0000-000000000003',
 'The Ryman Auditorium Bar', 'ryman-bar',
 'Historic bar inside the Mother Church of Country Music. Legendary venue with live performances.',
 'bar', '116 5th Ave N', 'Nashville', 'TN', '37219',
 ST_MakePoint(-86.7789, 36.1664)::geography,
 '+1-615-889-3060', '@rymanbarlive', 4.7, 3102, true, true,
 '{"mon":{"open":"08:00","close":"23:00"},"tue":{"open":"08:00","close":"23:00"},"wed":{"open":"08:00","close":"23:00"},"thu":{"open":"08:00","close":"00:00"},"fri":{"open":"08:00","close":"02:00"},"sat":{"open":"08:00","close":"02:00"},"sun":{"open":"08:00","close":"23:00"}}',
 ARRAY['live_music','historic','country','venue'], 3),

('10000000-0000-0000-0000-000000000004',
 'The Bluebird Cafe', 'bluebird-cafe',
 'Intimate Nashville legend where country stars write and perform their hits.',
 'bar', '4104 Nolensville Pike', 'Nashville', 'TN', '37211',
 ST_MakePoint(-86.7584, 36.0848)::geography,
 '+1-615-383-1461', '@bluebirdcafe', 4.8, 4287, true, true,
 '{"tue":{"open":"17:00","close":"00:00"},"wed":{"open":"17:00","close":"00:00"},"thu":{"open":"17:00","close":"00:00"},"fri":{"open":"17:00","close":"02:00"},"sat":{"open":"17:00","close":"02:00"},"sun":{"open":"17:00","close":"23:00"}}',
 ARRAY['live_music','country','songwriting','intimate'], 3),

('10000000-0000-0000-0000-000000000005',
 'Tootsie''s Orchid Lounge', 'tootsies-orchid',
 'Iconic Broadway institution since 1960. Three floors of country music, dancers, and classic Nashville.',
 'bar', '422 Broadway', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7797, 36.1593)::geography,
 '+1-615-726-0463', '@toots_orchid', 4.4, 3456, true, true,
 '{"mon":{"open":"10:00","close":"03:00"},"tue":{"open":"10:00","close":"03:00"},"wed":{"open":"10:00","close":"03:00"},"thu":{"open":"10:00","close":"03:00"},"fri":{"open":"10:00","close":"04:00"},"sat":{"open":"10:00","close":"04:00"},"sun":{"open":"10:00","close":"03:00"}}',
 ARRAY['live_music','dancers','country','historic'], 2),

('10000000-0000-0000-0000-000000000006',
 'Jason Aldean''s Kitchen + Rooftop', 'aldean-kitchen',
 'Two-level venue by Jason Aldean with Southern food and country music entertainment.',
 'restaurant', '307 Broadway', 'Nashville', 'TN', '37201',
 ST_MakePoint(-86.7798, 36.1602)::geography,
 '+1-615-249-6024', '@aldeankitchen', 4.5, 2134, true, true,
 '{"mon":{"open":"10:30","close":"01:00"},"tue":{"open":"10:30","close":"01:00"},"wed":{"open":"10:30","close":"01:00"},"thu":{"open":"10:30","close":"01:00"},"fri":{"open":"10:30","close":"02:00"},"sat":{"open":"10:30","close":"02:00"},"sun":{"open":"10:30","close":"23:00"}}',
 ARRAY['live_music','southern_food','rooftop','country'], 3),

('10000000-0000-0000-0000-000000000007',
 'Acme Feed & Seed', 'acme-feed',
 'Rooftop bar and concert hall on Broadway with incredible views and live music.',
 'bar', '101 Broadway', 'Nashville', 'TN', '37201',
 ST_MakePoint(-86.7758, 36.1629)::geography,
 '+1-615-915-0888', '@acmefeedandseed', 4.6, 2245, true, true,
 '{"mon":{"open":"11:00","close":"03:00"},"tue":{"open":"11:00","close":"03:00"},"wed":{"open":"11:00","close":"03:00"},"thu":{"open":"11:00","close":"03:00"},"fri":{"open":"11:00","close":"04:00"},"sat":{"open":"11:00","close":"04:00"},"sun":{"open":"11:00","close":"02:00"}}',
 ARRAY['rooftop','live_music','views','country'], 2),

('10000000-0000-0000-0000-000000000008',
 'Nudie''s Honky Tonk', 'nudies-honky-tonk',
 'Electric Broadway honky tonk with live bands nightly and energetic dancing.',
 'bar', '409 Broadway', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7804, 36.1595)::geography,
 '+1-615-726-0047', '@nudiesbroadway', 4.5, 1876, true, true,
 '{"mon":{"open":"11:00","close":"03:00"},"tue":{"open":"11:00","close":"03:00"},"wed":{"open":"11:00","close":"03:00"},"thu":{"open":"11:00","close":"03:00"},"fri":{"open":"11:00","close":"04:00"},"sat":{"open":"11:00","close":"04:00"},"sun":{"open":"11:00","close":"02:00"}}',
 ARRAY['live_music','dancing','honky_tonk','country'], 2),

('10000000-0000-0000-0000-000000000009',
 'The Parthenon Bar & Grill', 'parthenon-bar',
 'Greek-themed bar with Southern comfort food, craft cocktails, and vintage vibes.',
 'bar', '2610 West End Ave', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.8069, 36.1447)::geography,
 '+1-615-329-1313', '@parthenon_bar', 4.4, 987, true, false,
 '{"mon":{"open":"11:00","close":"00:00"},"tue":{"open":"11:00","close":"00:00"},"wed":{"open":"11:00","close":"01:00"},"thu":{"open":"11:00","close":"01:00"},"fri":{"open":"11:00","close":"02:00"},"sat":{"open":"12:00","close":"02:00"},"sun":{"open":"12:00","close":"23:00"}}',
 ARRAY['craft_cocktails','comfort_food','greek','vintage'], 2),

('10000000-0000-0000-0000-000000000010',
 'Winner''s Bar', 'winners-bar',
 'Classic Broadway sports bar with multiple screens, wings, and cold beers.',
 'bar', '300 Broadway', 'Nashville', 'TN', '37201',
 ST_MakePoint(-86.7799, 36.1608)::geography,
 '+1-615-251-0099', '@winnersbroadway', 4.2, 612, true, false,
 '{"mon":{"open":"10:00","close":"03:00"},"tue":{"open":"10:00","close":"03:00"},"wed":{"open":"10:00","close":"03:00"},"thu":{"open":"10:00","close":"03:00"},"fri":{"open":"10:00","close":"04:00"},"sat":{"open":"10:00","close":"04:00"},"sun":{"open":"10:00","close":"02:00"}}',
 ARRAY['sports','wings','beer','tvs'], 1),

-- MIDTOWN RESTAURANTS & CRAFT BARS (15 venues)
('10000000-0000-0000-0000-000000000011',
 'The 5 Spot', 'the-5-spot',
 'Iconic Midtown dive bar with Southern food, strong drinks, and live music.',
 'bar', '1006 Main St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7629, 36.1543)::geography,
 '+1-615-650-9333', '@the5spotnash', 4.5, 2134, true, true,
 '{"mon":{"open":"16:00","close":"02:00"},"tue":{"open":"16:00","close":"02:00"},"wed":{"open":"16:00","close":"02:00"},"thu":{"open":"16:00","close":"02:00"},"fri":{"open":"16:00","close":"03:00"},"sat":{"open":"16:00","close":"03:00"},"sun":{"open":"16:00","close":"02:00"}}',
 ARRAY['dive_bar','live_music','southern_food','classic'], 1),

('10000000-0000-0000-0000-000000000012',
 'Attaboy Nashville', 'attaboy-nashville',
 'No-menu craft cocktail bar in Midtown. Tell your flavor preference, they craft your perfect drink.',
 'bar', '1203 6th Ave N', 'Nashville', 'TN', '37208',
 ST_MakePoint(-86.7744, 36.1631)::geography,
 '+1-615-942-5545', '@attaboybar', 4.7, 1456, true, true,
 '{"tue":{"open":"17:00","close":"01:00"},"wed":{"open":"17:00","close":"01:00"},"thu":{"open":"17:00","close":"02:00"},"fri":{"open":"17:00","close":"02:00"},"sat":{"open":"17:00","close":"02:00"},"sun":{"open":"17:00","close":"23:00"}}',
 ARRAY['craft_cocktails','no_menu','intimate','artisanal'], 3),

('10000000-0000-0000-0000-000000000013',
 'JM', 'jm-restaurant',
 'Upscale American restaurant in Midtown with craft cocktails and Southern-inspired cuisine.',
 'restaurant', '1238 Villa Pl', 'Nashville', 'TN', '37212',
 ST_MakePoint(-86.7863, 36.1408)::geography,
 '+1-615-383-4800', '@jm_midtown', 4.6, 2876, true, true,
 '{"tue":{"open":"17:30","close":"22:00"},"wed":{"open":"17:30","close":"22:00"},"thu":{"open":"17:30","close":"22:00"},"fri":{"open":"17:30","close":"23:00"},"sat":{"open":"17:30","close":"23:00"},"sun":{"open":"17:00","close":"21:00"}}',
 ARRAY['upscale','american','craft_cocktails','southern'], 4),

('10000000-0000-0000-0000-000000000014',
 'Skull''s Rainbow Room', 'skulls-rainbow',
 'Bohemian honky tonk in Midtown with live music, craft cocktails, and eclectic crowd.',
 'bar', '1004 Main St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7627, 36.1548)::geography,
 '+1-615-226-3181', '@skullsrainbow', 4.4, 1723, true, true,
 '{"mon":{"open":"16:00","close":"02:00"},"tue":{"open":"16:00","close":"02:00"},"wed":{"open":"16:00","close":"02:00"},"thu":{"open":"16:00","close":"03:00"},"fri":{"open":"16:00","close":"03:00"},"sat":{"open":"16:00","close":"03:00"},"sun":{"open":"16:00","close":"02:00"}}',
 ARRAY['live_music','craft_cocktails','bohemian','eclectic'], 2),

('10000000-0000-0000-0000-000000000015',
 'The Treehouse', 'the-treehouse',
 'Rooftop beer garden in Midtown with craft beers, food trucks, and chill vibes.',
 'bar', '1008 Main St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7631, 36.1541)::geography,
 '+1-615-915-0999', '@thetreehouse_tn', 4.5, 1834, true, true,
 '{"tue":{"open":"16:00","close":"23:00"},"wed":{"open":"16:00","close":"23:00"},"thu":{"open":"16:00","close":"00:00"},"fri":{"open":"16:00","close":"01:00"},"sat":{"open":"11:00","close":"01:00"},"sun":{"open":"11:00","close":"23:00"}}',
 ARRAY['rooftop','beer_garden','craft_beer','food_trucks'], 1),

('10000000-0000-0000-0000-000000000016',
 'Etch Restaurant & Bar', 'etch-restaurant',
 'Modern American fine dining in Midtown with an exceptional bar program.',
 'restaurant', '1424 McGavock Pike', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7621, 36.1389)::geography,
 '+1-615-522-0685', '@etch_nashville', 4.7, 2145, true, true,
 '{"mon":{"open":"17:30","close":"22:00"},"tue":{"open":"17:30","close":"22:00"},"wed":{"open":"17:30","close":"22:00"},"thu":{"open":"17:30","close":"23:00"},"fri":{"open":"17:30","close":"23:00"},"sat":{"open":"17:30","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['fine_dining','american','craft_cocktails','upscale'], 4),

('10000000-0000-0000-0000-000000000017',
 'Neighbors', 'neighbors-restaurant',
 'Casual LGBTQ+ friendly bar and restaurant in Midtown with Southern comfort food.',
 'bar', '1519 Church St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7649, 36.1508)::geography,
 '+1-615-226-1288', '@neighborsbar', 4.3, 1567, true, true,
 '{"mon":{"open":"16:00","close":"02:00"},"tue":{"open":"16:00","close":"02:00"},"wed":{"open":"16:00","close":"02:00"},"thu":{"open":"16:00","close":"02:00"},"fri":{"open":"16:00","close":"03:00"},"sat":{"open":"16:00","close":"03:00"},"sun":{"open":"16:00","close":"02:00"}}',
 ARRAY['lgbtq','comfort_food','beer','drag_shows'], 2),

('10000000-0000-0000-0000-000000000018',
 'Barcadia Arcade Bar', 'barcadia-arcade',
 'Retro arcade bar with classic games, craft cocktails, and nostalgic fun.',
 'bar', '2411 Music Valley Dr', 'Nashville', 'TN', '37214',
 ST_MakePoint(-86.7421, 36.2015)::geography,
 '+1-615-833-2944', '@barcadia_arcade', 4.4, 1234, true, true,
 '{"tue":{"open":"17:00","close":"23:00"},"wed":{"open":"17:00","close":"23:00"},"thu":{"open":"17:00","close":"00:00"},"fri":{"open":"17:00","close":"01:00"},"sat":{"open":"13:00","close":"01:00"},"sun":{"open":"13:00","close":"23:00"}}',
 ARRAY['arcade_games','craft_cocktails','retro','fun'], 1),

('10000000-0000-0000-0000-000000000019',
 'The Patterson House', 'patterson-house',
 'Speakeasy-style cocktail bar in Midtown with craft drinks and intimate ambiance.',
 'bar', '1711 Division St', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7577, 36.1490)::geography,
 '+1-615-636-7724', '@patterson_house', 4.6, 2234, true, true,
 '{"tue":{"open":"17:00","close":"02:00"},"wed":{"open":"17:00","close":"02:00"},"thu":{"open":"17:00","close":"02:00"},"fri":{"open":"17:00","close":"03:00"},"sat":{"open":"17:00","close":"03:00"},"sun":{"open":"17:00","close":"00:00"}}',
 ARRAY['speakeasy','craft_cocktails','intimate','sophisticated'], 3),

('10000000-0000-0000-0000-000000000020',
 'Golden Sound Studio Bar', 'golden-sound',
 'Music-themed bar with vinyl records, craft cocktails, and live performances.',
 'bar', '914 Main St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7617, 36.1564)::geography,
 '+1-615-254-5656', '@goldensound_bar', 4.5, 1645, true, true,
 '{"mon":{"open":"16:00","close":"23:00"},"tue":{"open":"16:00","close":"00:00"},"wed":{"open":"16:00","close":"00:00"},"thu":{"open":"16:00","close":"01:00"},"fri":{"open":"16:00","close":"02:00"},"sat":{"open":"16:00","close":"02:00"},"sun":{"open":"16:00","close":"23:00"}}',
 ARRAY['live_music','vinyl','craft_cocktails','music_themed'], 2),

('10000000-0000-0000-0000-000000000021',
 'Sambuca Nashville', 'sambuca-nashville',
 'Italian restaurant with elegant bar, wine selection, and fine dining experience.',
 'restaurant', '2301 Sidco Dr', 'Nashville', 'TN', '37204',
 ST_MakePoint(-86.7451, 36.1217)::geography,
 '+1-615-777-1193', '@sambuca_nash', 4.5, 1876, true, true,
 '{"mon":{"open":"17:30","close":"22:00"},"tue":{"open":"17:30","close":"22:00"},"wed":{"open":"17:30","close":"22:00"},"thu":{"open":"17:30","close":"23:00"},"fri":{"open":"17:30","close":"23:00"},"sat":{"open":"17:30","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['italian','fine_dining','wine','upscale'], 4),

('10000000-0000-0000-0000-000000000022',
 'The 3 Keys Bar & Grill', 'three-keys-bar',
 'Sports bar and grill with multiple screens, wings, and burgers in Midtown.',
 'bar', '1008 Division St', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7574, 36.1497)::geography,
 '+1-615-259-4234', '@threekeys_bar', 4.2, 987, true, false,
 '{"mon":{"open":"11:00","close":"23:00"},"tue":{"open":"11:00","close":"23:00"},"wed":{"open":"11:00","close":"23:00"},"thu":{"open":"11:00","close":"00:00"},"fri":{"open":"11:00","close":"01:00"},"sat":{"open":"11:00","close":"01:00"},"sun":{"open":"11:00","close":"23:00"}}',
 ARRAY['sports','wings','burgers','beer'], 1),

('10000000-0000-0000-0000-000000000023',
 'The Hermitage Hotel Bar', 'hermitage-hotel-bar',
 'Historic luxury hotel bar with upscale cocktails, fine dining, and Southern elegance.',
 'lounge', '231 6th Ave N', 'Nashville', 'TN', '37219',
 ST_MakePoint(-86.7774, 36.1652)::geography,
 '+1-615-244-3121', '@hermitagehotel', 4.7, 2345, true, true,
 '{"mon":{"open":"11:00","close":"01:00"},"tue":{"open":"11:00","close":"01:00"},"wed":{"open":"11:00","close":"01:00"},"thu":{"open":"11:00","close":"02:00"},"fri":{"open":"11:00","close":"02:00"},"sat":{"open":"11:00","close":"02:00"},"sun":{"open":"12:00","close":"00:00"}}',
 ARRAY['hotel_bar','upscale','cocktails','historic'], 4),

('10000000-0000-0000-0000-000000000024',
 'Hustle & Vine Wine Bar', 'hustle-vine',
 'Wine bar and bistro in Midtown with wine flights, small plates, and cozy ambiance.',
 'bar', '1817 Elliston Pl', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7847, 36.1476)::geography,
 '+1-615-327-7055', '@hustleandvine', 4.4, 1123, true, true,
 '{"tue":{"open":"16:00","close":"22:00"},"wed":{"open":"16:00","close":"22:00"},"thu":{"open":"16:00","close":"23:00"},"fri":{"open":"16:00","close":"00:00"},"sat":{"open":"13:00","close":"00:00"},"sun":{"open":"13:00","close":"22:00"}}',
 ARRAY['wine','bistro','small_plates','cozy'], 2),

('10000000-0000-0000-0000-000000000025',
 'Tennessee Brew Works', 'tennessee-brew-works',
 'Local brewery and tap house in Midtown with craft beers and food trucks.',
 'bar', '809 Ewing Ave E', 'Nashville', 'TN', '37207',
 ST_MakePoint(-86.7428, 36.1714)::geography,
 '+1-615-742-2739', '@tbrew_works', 4.5, 1567, true, true,
 '{"mon":{"open":"16:00","close":"23:00"},"tue":{"open":"16:00","close":"23:00"},"wed":{"open":"16:00","close":"23:00"},"thu":{"open":"16:00","close":"00:00"},"fri":{"open":"13:00","close":"01:00"},"sat":{"open":"13:00","close":"01:00"},"sun":{"open":"13:00","close":"23:00"}}',
 ARRAY['craft_beer','brewery','food_trucks','local'], 1),

-- EAST NASHVILLE BARS & VENUES (15 venues)
('10000000-0000-0000-0000-000000000026',
 'Basement East', 'basement-east',
 'Music venue and bar under the street in East Nashville with live shows and craft cocktails.',
 'bar', '1315 Dickerson Pike', 'Nashville', 'TN', '37207',
 ST_MakePoint(-86.7336, 36.1789)::geography,
 '+1-615-645-9174', '@basementeast', 4.6, 2134, true, true,
 '{"fri":{"open":"18:00","close":"03:00"},"sat":{"open":"18:00","close":"03:00"},"sun":{"open":"18:00","close":"02:00"}}',
 ARRAY['live_music','underground','craft_cocktails','venue'], 2),

('10000000-0000-0000-0000-000000000027',
 'Lipstick Lounge', 'lipstick-lounge',
 'LGBTQ+ bar and lounge in East Nashville with drag shows and live entertainment.',
 'bar', '1400 Woodland St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7459, 36.1524)::geography,
 '+1-615-226-6343', '@lipstick_lounge', 4.5, 1876, true, true,
 '{"mon":{"open":"20:00","close":"03:00"},"tue":{"open":"20:00","close":"03:00"},"wed":{"open":"20:00","close":"03:00"},"thu":{"open":"20:00","close":"03:00"},"fri":{"open":"20:00","close":"04:00"},"sat":{"open":"20:00","close":"04:00"},"sun":{"open":"20:00","close":"03:00"}}',
 ARRAY['lgbtq','drag_shows','dance','lounge'], 2),

('10000000-0000-0000-0000-000000000028',
 'The Stone Fox Tap', 'stone-fox',
 'Casual dive bar in East Nashville with craft beers, food, and laid-back atmosphere.',
 'bar', '1213 Dickerson Pike', 'Nashville', 'TN', '37207',
 ST_MakePoint(-86.7335, 36.1807)::geography,
 '+1-615-217-3370', '@thestonefox', 4.4, 1345, true, true,
 '{"mon":{"open":"15:00","close":"01:00"},"tue":{"open":"15:00","close":"01:00"},"wed":{"open":"15:00","close":"01:00"},"thu":{"open":"15:00","close":"02:00"},"fri":{"open":"15:00","close":"02:00"},"sat":{"open":"13:00","close":"02:00"},"sun":{"open":"13:00","close":"01:00"}}',
 ARRAY['craft_beer','dive_bar','food','laid_back'], 1),

('10000000-0000-0000-0000-000000000029',
 'Sad Dawgz East Bar', 'sad-dawgz',
 'Dog-friendly East Nashville bar with wood-fired pizza and craft beers.',
 'bar', '1804 Eastland Ave', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7425, 36.1470)::geography,
 '+1-615-262-3345', '@saddawgzbar', 4.6, 1523, true, true,
 '{"mon":{"open":"16:00","close":"00:00"},"tue":{"open":"16:00","close":"00:00"},"wed":{"open":"16:00","close":"00:00"},"thu":{"open":"16:00","close":"01:00"},"fri":{"open":"16:00","close":"02:00"},"sat":{"open":"13:00","close":"02:00"},"sun":{"open":"13:00","close":"00:00"}}',
 ARRAY['dog_friendly','pizza','craft_beer','outdoor'], 2),

('10000000-0000-0000-0000-000000000030',
 'The Five Points Pizza', 'five-points-pizza',
 'Pizza and beer spot in East Nashville with craft cocktails and outdoor seating.',
 'restaurant', '1012 Woodland St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7484, 36.1559)::geography,
 '+1-615-649-4033', '@fivepointstnxnashville', 4.5, 1234, true, true,
 '{"mon":{"open":"11:00","close":"22:00"},"tue":{"open":"11:00","close":"22:00"},"wed":{"open":"11:00","close":"22:00"},"thu":{"open":"11:00","close":"23:00"},"fri":{"open":"11:00","close":"23:00"},"sat":{"open":"11:00","close":"23:00"},"sun":{"open":"11:00","close":"22:00"}}',
 ARRAY['pizza','beer','craft_cocktails','outdoor'], 2),

('10000000-0000-0000-0000-000000000031',
 'Elberta Lofts', 'elberta-lofts',
 'Vintage event space and bar in East Nashville with retro vibes and craft cocktails.',
 'bar', '506 Elberta Ave', 'Nashville', 'TN', '37207',
 ST_MakePoint(-86.7402, 36.1705)::geography,
 '+1-615-454-9343', '@elberta_lofts', 4.3, 876, true, true,
 '{"fri":{"open":"19:00","close":"02:00"},"sat":{"open":"19:00","close":"02:00"},"sun":{"open":"19:00","close":"00:00"}}',
 ARRAY['vintage','event_space','craft_cocktails','retro'], 2),

('10000000-0000-0000-0000-000000000032',
 'Acme Feed & Seed East', 'acme-east',
 'Extended location of Acme with rooftop bar and live music in East Nashville.',
 'bar', '1510 Dickerson Pike', 'Nashville', 'TN', '37207',
 ST_MakePoint(-86.7297, 36.1785)::geography,
 '+1-615-450-9999', '@acmeeast', 4.5, 1456, true, true,
 '{"mon":{"open":"16:00","close":"23:00"},"tue":{"open":"16:00","close":"23:00"},"wed":{"open":"16:00","close":"23:00"},"thu":{"open":"16:00","close":"00:00"},"fri":{"open":"15:00","close":"02:00"},"sat":{"open":"15:00","close":"02:00"},"sun":{"open":"15:00","close":"23:00"}}',
 ARRAY['rooftop','live_music','beer','views'], 2),

('10000000-0000-0000-0000-000000000033',
 'Cannery Ballroom', 'cannery-ballroom',
 'Historic concert venue and bar in East Nashville with live music and craft cocktails.',
 'bar', '1 Cannery Row', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7694, 36.1378)::geography,
 '+1-615-514-3664', '@canneryballroom', 4.4, 2134, true, true,
 '{"fri":{"open":"19:00","close":"02:00"},"sat":{"open":"19:00","close":"02:00"},"sun":{"open":"19:00","close":"00:00"}}',
 ARRAY['live_music','concert_venue','craft_cocktails','historic'], 3),

('10000000-0000-0000-0000-000000000034',
 'Honky Tonk Heroes', 'honky-tonk-heroes',
 'Laid-back honky tonk in East Nashville with country music and strong pours.',
 'bar', '1428 McGavock Pike', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7623, 36.1387)::geography,
 '+1-615-225-4323', '@honkytonk_heroes', 4.3, 876, true, true,
 '{"mon":{"open":"16:00","close":"02:00"},"tue":{"open":"16:00","close":"02:00"},"wed":{"open":"16:00","close":"02:00"},"thu":{"open":"16:00","close":"02:00"},"fri":{"open":"16:00","close":"03:00"},"sat":{"open":"13:00","close":"03:00"},"sun":{"open":"13:00","close":"02:00"}}',
 ARRAY['honky_tonk','country','live_music','dive'], 1),

('10000000-0000-0000-0000-000000000035',
 'Runway Nashville', 'runway-nashville',
 'LGBTQ+ dance venue in East Nashville with live DJs and drag shows.',
 'bar', '1423 Elliston Pl', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7846, 36.1488)::geography,
 '+1-615-320-1449', '@runway_nash', 4.4, 1234, true, true,
 '{"fri":{"open":"21:00","close":"04:00"},"sat":{"open":"21:00","close":"04:00"},"sun":{"open":"21:00","close":"03:00"}}',
 ARRAY['lgbtq','dance','drag_shows','dj'], 2),

('10000000-0000-0000-0000-000000000036',
 'Tavern', 'tavern-east',
 'Upscale tavern in East Nashville with craft cocktails, beer, and elevated pub food.',
 'restaurant', '1904 Eastland Ave', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7414, 36.1460)::geography,
 '+1-615-262-0053', '@tavern_nash', 4.6, 1945, true, true,
 '{"mon":{"open":"17:00","close":"22:00"},"tue":{"open":"17:00","close":"22:00"},"wed":{"open":"17:00","close":"22:00"},"thu":{"open":"17:00","close":"23:00"},"fri":{"open":"17:00","close":"23:00"},"sat":{"open":"17:00","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['upscale','craft_cocktails','pub_food','beer'], 3),

('10000000-0000-0000-0000-000000000037',
 'The Ritz Theatre', 'ritz-theatre',
 'Historic music venue and bar in East Nashville with live shows and vintage charm.',
 'bar', '618 Commerce St', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7828, 36.1628)::geography,
 '+1-615-254-3522', '@theritztheatre', 4.5, 1876, true, true,
 '{"fri":{"open":"18:00","close":"02:00"},"sat":{"open":"18:00","close":"02:00"},"sun":{"open":"18:00","close":"00:00"}}',
 ARRAY['live_music','historic_venue','vintage','beer'], 2),

('10000000-0000-0000-0000-000000000038',
 'Lucky Bastard', 'lucky-bastard',
 'Casual bar in East Nashville with craft beer, shuffleboard, and good times.',
 'bar', '1608 4th Ave N', 'Nashville', 'TN', '37208',
 ST_MakePoint(-86.7771, 36.1689)::geography,
 '+1-615-922-2325', '@lucky_bastard', 4.4, 1123, true, true,
 '{"mon":{"open":"16:00","close":"00:00"},"tue":{"open":"16:00","close":"00:00"},"wed":{"open":"16:00","close":"00:00"},"thu":{"open":"16:00","close":"01:00"},"fri":{"open":"16:00","close":"02:00"},"sat":{"open":"13:00","close":"02:00"},"sun":{"open":"13:00","close":"00:00"}}',
 ARRAY['craft_beer','shuffleboard','casual','games'], 1),

('10000000-0000-0000-0000-000000000039',
 'Public House South', 'public-house-south',
 'Neighborhood pub in East Nashville with beer, spirits, and Southern comfort food.',
 'bar', '1500 James Robertson Parkway', 'Nashville', 'TN', '37213',
 ST_MakePoint(-86.7612, 36.1305)::geography,
 '+1-615-645-9874', '@publichsouth', 4.3, 987, true, true,
 '{"mon":{"open":"11:00","close":"23:00"},"tue":{"open":"11:00","close":"23:00"},"wed":{"open":"11:00","close":"23:00"},"thu":{"open":"11:00","close":"00:00"},"fri":{"open":"11:00","close":"01:00"},"sat":{"open":"11:00","close":"01:00"},"sun":{"open":"11:00","close":"23:00"}}',
 ARRAY['pub','beer','comfort_food','neighborhood'], 1),

('10000000-0000-0000-0000-000000000040',
 'Five Daughters Bakery & Bar', 'five-daughters',
 'Unique bakery and bar in East Nashville with craft donuts and creative cocktails.',
 'restaurant', '1110 Woodland St', 'Nashville', 'TN', '37206',
 ST_MakePoint(-86.7476, 36.1540)::geography,
 '+1-615-376-1440', '@fivedaughtersbake', 4.6, 2134, true, true,
 '{"mon":{"open":"07:00","close":"22:00"},"tue":{"open":"07:00","close":"22:00"},"wed":{"open":"07:00","close":"22:00"},"thu":{"open":"07:00","close":"23:00"},"fri":{"open":"07:00","close":"23:00"},"sat":{"open":"08:00","close":"23:00"},"sun":{"open":"08:00","close":"22:00"}}',
 ARRAY['bakery','donuts','craft_cocktails','unique'], 2),

-- NAPERVILLIE / GERMANTOWN AREA (10 venues)
('10000000-0000-0000-0000-000000000041',
 'The Printer''s Alley Distillery', 'printers-alley-distillery',
 'Craft distillery and bar on historic Printer''s Alley with whiskey and live music.',
 'bar', '611 Printer Alley', 'Nashville', 'TN', '37201',
 ST_MakePoint(-86.7817, 36.1662)::geography,
 '+1-615-782-1222', '@printersalley_dist', 4.5, 1567, true, true,
 '{"mon":{"open":"16:00","close":"23:00"},"tue":{"open":"16:00","close":"23:00"},"wed":{"open":"16:00","close":"23:00"},"thu":{"open":"16:00","close":"00:00"},"fri":{"open":"16:00","close":"01:00"},"sat":{"open":"13:00","close":"01:00"},"sun":{"open":"13:00","close":"23:00"}}',
 ARRAY['distillery','whiskey','craft_spirits','live_music'], 3),

('10000000-0000-0000-0000-000000000042',
 'Ole Smoky Distillery', 'ole-smoky',
 'Tennessee moonshine distillery and bar with live entertainment and tastings.',
 'bar', '1220 Old Hickory Blvd', 'Nashville', 'TN', '37217',
 ST_MakePoint(-86.6832, 36.1798)::geography,
 '+1-615-883-4040', '@olesmokydistillery', 4.4, 2876, true, true,
 '{"mon":{"open":"10:00","close":"22:00"},"tue":{"open":"10:00","close":"22:00"},"wed":{"open":"10:00","close":"22:00"},"thu":{"open":"10:00","close":"23:00"},"fri":{"open":"10:00","close":"23:00"},"sat":{"open":"10:00","close":"23:00"},"sun":{"open":"10:00","close":"22:00"}}',
 ARRAY['moonshine','distillery','live_music','tastings'], 2),

('10000000-0000-0000-0000-000000000043',
 'Germantown Cafe', 'germantown-cafe',
 'Vintage cafe and bar in Germantown with cocktails, coffee, and artisan food.',
 'restaurant', '1215 5th Ave N', 'Nashville', 'TN', '37208',
 ST_MakePoint(-86.7785, 36.1634)::geography,
 '+1-615-254-2788', '@germantown_cafe', 4.5, 1345, true, true,
 '{"mon":{"open":"07:00","close":"22:00"},"tue":{"open":"07:00","close":"22:00"},"wed":{"open":"07:00","close":"22:00"},"thu":{"open":"07:00","close":"23:00"},"fri":{"open":"07:00","close":"23:00"},"sat":{"open":"08:00","close":"23:00"},"sun":{"open":"08:00","close":"22:00"}}',
 ARRAY['cafe','cocktails','coffee','artisan'], 2),

('10000000-0000-0000-0000-000000000044',
 'Doyle & Debbie Restaurant', 'doyle-debbie',
 'Southern bistro in Germantown with craft cocktails and upscale casual dining.',
 'restaurant', '1115 4th Ave', 'Nashville', 'TN', '37208',
 ST_MakePoint(-86.7750, 36.1678)::geography,
 '+1-615-277-3600', '@doyle_debbie', 4.6, 1876, true, true,
 '{"mon":{"open":"17:00","close":"22:00"},"tue":{"open":"17:00","close":"22:00"},"wed":{"open":"17:00","close":"22:00"},"thu":{"open":"17:00","close":"23:00"},"fri":{"open":"17:00","close":"23:00"},"sat":{"open":"17:00","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['southern','bistro','craft_cocktails','upscale'], 3),

('10000000-0000-0000-0000-000000000045',
 'The Catbird Seat', 'catbird-seat',
 'Intimate chef''s counter restaurant with an exceptional cocktail bar.',
 'restaurant', '1711 Division St', 'Nashville', 'TN', '37203',
 ST_MakePoint(-86.7577, 36.1490)::geography,
 '+1-615-810-8200', '@catbird_seat', 4.7, 1456, true, true,
 '{"tue":{"open":"17:00","close":"23:00"},"wed":{"open":"17:00","close":"23:00"},"thu":{"open":"17:00","close":"23:00"},"fri":{"open":"17:00","close":"23:00"},"sat":{"open":"17:00","close":"23:00"}}',
 ARRAY['fine_dining','chef''s_counter','cocktails','upscale'], 4),

('10000000-0000-0000-0000-000000000046',
 'The Memphis Taproom', 'memphis-taproom',
 'Beer bar with craft selections, spirits, and Tennessee craft beverages.',
 'bar', '1624 4th Ave N', 'Nashville', 'TN', '37208',
 ST_MakePoint(-86.7773, 36.1681)::geography,
 '+1-615-284-5866', '@memphis_taproom', 4.4, 1234, true, true,
 '{"mon":{"open":"16:00","close":"23:00"},"tue":{"open":"16:00","close":"23:00"},"wed":{"open":"16:00","close":"23:00"},"thu":{"open":"16:00","close":"00:00"},"fri":{"open":"16:00","close":"01:00"},"sat":{"open":"13:00","close":"01:00"},"sun":{"open":"13:00","close":"23:00"}}',
 ARRAY['craft_beer','taproom','spirits','casual'], 1),

('10000000-0000-0000-0000-000000000047',
 'Watkins Park Restaurant', 'watkins-park',
 'Upscale Southern restaurant with craft cocktails and intimate dining.',
 'restaurant', '2804 Columbine Pl', 'Nashville', 'TN', '37204',
 ST_MakePoint(-86.7523, 36.1108)::geography,
 '+1-615-463-2892', '@watkins_park', 4.5, 1567, true, true,
 '{"mon":{"open":"17:30","close":"22:00"},"tue":{"open":"17:30","close":"22:00"},"wed":{"open":"17:30","close":"22:00"},"thu":{"open":"17:30","close":"23:00"},"fri":{"open":"17:30","close":"23:00"},"sat":{"open":"17:30","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['southern','upscale','craft_cocktails','intimate'], 3),

('10000000-0000-0000-0000-000000000048',
 'Butcher & Bee', 'butcher-bee',
 'Modern restaurant with craft cocktails, seasonal menu, and charcuterie.',
 'restaurant', '1814 4th Ave N', 'Nashville', 'TN', '37208',
 ST_MakePoint(-86.7790, 36.1664)::geography,
 '+1-615-226-3100', '@butcher_bee', 4.6, 2134, true, true,
 '{"mon":{"open":"17:30","close":"22:00"},"tue":{"open":"17:30","close":"22:00"},"wed":{"open":"17:30","close":"22:00"},"thu":{"open":"17:30","close":"23:00"},"fri":{"open":"17:30","close":"23:00"},"sat":{"open":"17:30","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['modern','charcuterie','craft_cocktails','seasonal'], 3),

('10000000-0000-0000-0000-000000000049',
 'The Analog Restaurant', 'analog-restaurant',
 'Casual restaurant with craft cocktails, wood-fired pizza, and local vibes.',
 'restaurant', '1711 Westwood Ave', 'Nashville', 'TN', '37212',
 ST_MakePoint(-86.7870, 36.1396)::geography,
 '+1-615-319-2900', '@analog_tnx', 4.5, 1456, true, true,
 '{"mon":{"open":"17:00","close":"22:00"},"tue":{"open":"17:00","close":"22:00"},"wed":{"open":"17:00","close":"22:00"},"thu":{"open":"17:00","close":"23:00"},"fri":{"open":"17:00","close":"23:00"},"sat":{"open":"17:00","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['casual','craft_cocktails','pizza','local'], 2),

('10000000-0000-0000-0000-000000000050',
 'Cote Restaurant', 'cote-restaurant',
 'Korean steakhouse with craft cocktails, wagyu, and upscale dining.',
 'restaurant', '1121 4th Ave N', 'Nashville', 'TN', '37208',
 ST_MakePoint(-86.7745, 36.1675)::geography,
 '+1-615-988-3700', '@cote_nashville', 4.7, 1987, true, true,
 '{"tue":{"open":"17:30","close":"22:00"},"wed":{"open":"17:30","close":"22:00"},"thu":{"open":"17:30","close":"22:00"},"fri":{"open":"17:30","close":"23:00"},"sat":{"open":"17:30","close":"23:00"},"sun":{"open":"17:00","close":"22:00"}}',
 ARRAY['korean','steakhouse','wagyu','upscale'], 4);

-- ── 200 DEALS ────────────────────────────────────────────────

-- Generate 200 deals across 50 venues
-- Mix of deal types: happy hours, food specials, flash deals, 2-for-1s

-- BROADWAY HONKY TONKS (40 deals)
INSERT INTO deals (id, venue_id, title, description, category, discount_type, discount_value, original_price, deal_price, starts_at, expires_at, is_active, is_featured, max_redemptions, tags) VALUES

-- Honky Tonk Central (8 deals)
('d0000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001',
 'Happy Hour: $4 Wells Mon-Fri', '$4 domestic wells, $5 premium wells during happy hour 4-7pm.',
 'drink', 'fixed', 4.00, NULL, NULL, NOW(), NOW() + INTERVAL '1 day', true, true, 200,
 ARRAY['happy_hour','wells','monday','tuesday','wednesday','thursday','friday']),

('d0000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001',
 '2-for-1 Margaritas Tonight', 'Buy one margarita, get one free tonight only 8pm-midnight.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '8 hours', true, true, 150,
 ARRAY['margaritas','2for1','flash_deal','tonight']),

('d0000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001',
 'Fried Chicken Basket + Beer $14', 'Nashville hot fried chicken basket with any beer for $14.',
 'combo', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '12 hours', true, false, 100,
 ARRAY['fried_chicken','beer','combo','food']),

('d0000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001',
 '20% Off All Appetizers', '20% off all shareable appetizers after 5pm.',
 'food', 'percentage', 20.00, NULL, NULL, NOW(), NOW() + INTERVAL '10 hours', true, true, 75,
 ARRAY['appetizers','food','discount','shareable']),

('d0000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000001',
 'Line Dancing Lesson + Drink $10', 'Free line dancing lesson with any drink purchase.',
 'combo', 'special', NULL, NULL, 10.00, NOW() + INTERVAL '3 hours', NOW() + INTERVAL '6 hours', true, false, 50,
 ARRAY['line_dance','lesson','drink','event']),

('d0000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000001',
 'Free Shot with Entrée', 'Free shot of Jack Daniel''s with any food entrée.',
 'free', NULL, NULL, NULL, NULL, NOW(), NOW() + INTERVAL '9 hours', true, false, 60,
 ARRAY['shot','entrée','free','whiskey']),

('d0000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000001',
 'Wings & Pitcher $28', 'Basket of wings + pitcher of domestic beer for $28.',
 'combo', 'special', NULL, NULL, 28.00, NOW(), NOW() + INTERVAL '11 hours', true, true, 80,
 ARRAY['wings','beer','pitcher','combo','food']),

('d0000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000001',
 '$3 Off All Cocktails 4-6pm', 'All cocktails $3 off during early happy hour.',
 'drink', 'fixed', 3.00, NULL, NULL, NOW(), NOW() + INTERVAL '3 hours', true, true, 200,
 ARRAY['cocktails','happy_hour','discount','early']),

-- Luke''s 32 Bridge Burn (8 deals)
('d0000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000002',
 'Luke''s Special: $15 Craft Cocktail', 'Any craft cocktail on Luke''s menu for $15 (normally $18+).',
 'drink', 'fixed', 3.00, 18.00, 15.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 150,
 ARRAY['craft_cocktail','luke_special','discount','artisanal']),

('d0000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000002',
 '2-for-1 Drafts Before 7pm', 'Buy one draft, get one free before 7pm daily.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 100,
 ARRAY['draft_beer','2for1','happy_hour','early']),

('d0000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000002',
 'Rooftop Sunset Happy Hour $5 Apps', 'Select appetizers $5 during sunset happy hour 5-7pm.',
 'food', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 80,
 ARRAY['appetizers','rooftop','happy_hour','sunset']),

('d0000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000002',
 'Burger + Craft Beer Combo $19', 'Premium burger + any craft beer for $19 (save $8).',
 'combo', 'fixed', 8.00, 27.00, 19.00, NOW(), NOW() + INTERVAL '12 hours', true, false, 120,
 ARRAY['burger','beer','combo','food','discount']),

('d0000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000002',
 'Live Music + 20% Off Food', '20% off all food when live music is playing.',
 'food', 'percentage', 20.00, NULL, NULL, NOW() + INTERVAL '4 hours', NOW() + INTERVAL '8 hours', true, false, 75,
 ARRAY['food','discount','live_music','entertainment']),

('d0000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000002',
 'Whiskey Flight + Appetizer $24', 'Three-pour whiskey flight paired with shareable appetizer.',
 'combo', 'special', NULL, NULL, 24.00, NOW(), NOW() + INTERVAL '11 hours', true, true, 90,
 ARRAY['whiskey','flight','appetizer','combo','tasting']),

('d0000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000002',
 'Late Night Deals After 10pm: 25% Off', '25% off all food orders after 10pm.',
 'food', 'percentage', 25.00, NULL, NULL, NOW() + INTERVAL '7 hours', NOW() + INTERVAL '14 hours', true, true, 100,
 ARRAY['late_night','discount','food','after_10pm']),

('d0000000-0000-0000-0000-000000000016', '10000000-0000-0000-0000-000000000002',
 'Free Appetizer with 3+ Drinks', 'Get a free appetizer when you order 3 or more drinks.',
 'free', NULL, NULL, NULL, NULL, NOW(), NOW() + INTERVAL '10 hours', true, false, 70,
 ARRAY['appetizer','free','drinks','promotion']),

-- Ryman Bar (8 deals)
('d0000000-0000-0000-0000-000000000017', '10000000-0000-0000-0000-000000000003',
 'Legendary Happy Hour: $4 Drafts', '$4 domestic drafts 4-7pm weekdays at the Mother Church.',
 'drink', 'fixed', 4.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 200,
 ARRAY['draft','happy_hour','domestic','weekday']),

('d0000000-0000-0000-0000-000000000018', '10000000-0000-0000-0000-000000000003',
 'Buy 1 Whiskey, Get 1 25% Off', 'Buy any whiskey, get a second whiskey 25% off.',
 'drink', 'percentage', 25.00, NULL, NULL, NOW(), NOW() + INTERVAL '11 hours', true, true, 120,
 ARRAY['whiskey','discount','bogo_style','spirits']),

('d0000000-0000-0000-0000-000000000019', '10000000-0000-0000-0000-000000000003',
 'Historic Hall Appetizer Special $7', 'Select historic-themed appetizers $7 (normally $12).',
 'food', 'fixed', 5.00, 12.00, 7.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 100,
 ARRAY['appetizer','historic','discount','special']),

('d0000000-0000-0000-0000-000000000020', '10000000-0000-0000-0000-000000000003',
 'Live Concert Night: $2 Off Drinks', '$2 off any drink during concert performances.',
 'drink', 'fixed', 2.00, NULL, NULL, NOW() + INTERVAL '4 hours', NOW() + INTERVAL '10 hours', true, true, 150,
 ARRAY['live_music','concert','discount','drink']),

('d0000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000003',
 'Beer + Nachos Combo $15', 'Large nachos with any beer for $15.',
 'combo', 'special', NULL, NULL, 15.00, NOW(), NOW() + INTERVAL '8 hours', true, true, 85,
 ARRAY['nachos','beer','combo','food']),

('d0000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000003',
 'Moonshine Tasting Special $20', 'Five-pour Tennessee moonshine flight with notes.',
 'drink', 'special', NULL, NULL, 20.00, NOW(), NOW() + INTERVAL '10 hours', true, false, 60,
 ARRAY['moonshine','tasting','flight','special']),

('d0000000-0000-0000-0000-000000000023', '10000000-0000-0000-0000-000000000003',
 'Free Wings with Pitcher Purchase', 'Free order of wings with pitcher of beer.',
 'free', NULL, NULL, NULL, NULL, NOW(), NOW() + INTERVAL '7 hours', true, true, 50,
 ARRAY['wings','beer','free','pitcher']),

('d0000000-0000-0000-0000-000000000024', '10000000-0000-0000-0000-000000000003',
 'Sunday Country Brunch: $18 w/ Drink', 'Full brunch plate with any bloody mary or mimosa.',
 'combo', 'special', NULL, NULL, 18.00, NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days 4 hours', true, true, 120,
 ARRAY['brunch','sunday','drink','food','combo']),

-- Continue with remaining Broadway venues...
-- Bluebird Cafe (8 deals)
('d0000000-0000-0000-0000-000000000025', '10000000-0000-0000-0000-000000000004',
 'Songwriter''s Night: 2-for-1 Drinks', 'Buy any drink, get a second one free on songwriter nights.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '6 hours', true, true, 100,
 ARRAY['2for1','songwriter','live_music','special']),

('d0000000-0000-0000-0000-000000000026', '10000000-0000-0000-0000-000000000004',
 'Dinner + Show Special $35', 'Entree + drink + live performance for $35.',
 'combo', 'special', NULL, NULL, 35.00, NOW(), NOW() + INTERVAL '5 hours', true, true, 80,
 ARRAY['dinner','live_music','combo','special']),

('d0000000-0000-0000-0000-000000000027', '10000000-0000-0000-0000-000000000004',
 'Cocktail + Chicken Tenders $16', 'Craft cocktail with homemade chicken tenders.',
 'combo', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 70,
 ARRAY['cocktail','chicken','combo','food']),

('d0000000-0000-0000-0000-000000000028', '10000000-0000-0000-0000-000000000004',
 '15% Off All Wine Bottles', '15% off any bottle of wine from our curated selection.',
 'drink', 'percentage', 15.00, NULL, NULL, NOW(), NOW() + INTERVAL '12 hours', true, true, 60,
 ARRAY['wine','discount','bottle','spirits']),

('d0000000-0000-0000-0000-000000000029', '10000000-0000-0000-0000-000000000004',
 'Early Bird Special: 5-6pm $12', 'Select entrees $12 during early bird hour 5-6pm.',
 'food', 'special', NULL, NULL, 12.00, NOW(), NOW() + INTERVAL '4 hours', true, true, 90,
 ARRAY['early_bird','discount','entree','food']),

('d0000000-0000-0000-0000-000000000030', '10000000-0000-0000-0000-000000000004',
 'Free Dessert with Dinner', 'Complimentary dessert with any dinner entree.',
 'free', NULL, NULL, NULL, NULL, NOW(), NOW() + INTERVAL '10 hours', true, false, 75,
 ARRAY['dessert','free','dinner','special']),

('d0000000-0000-0000-0000-000000000031', '10000000-0000-0000-0000-000000000004',
 'Happy Hour Appetizers: 2 for $12', 'Any two appetizers for $12 during happy hour.',
 'food', 'special', NULL, NULL, 12.00, NOW(), NOW() + INTERVAL '5 hours', true, true, 100,
 ARRAY['appetizers','happy_hour','deal','food']),

('d0000000-0000-0000-0000-000000000032', '10000000-0000-0000-0000-000000000004',
 'Wine Flight + Cheese Board $22', 'Three-pour wine flight paired with artisan cheese.',
 'combo', 'special', NULL, NULL, 22.00, NOW(), NOW() + INTERVAL '8 hours', true, true, 65,
 ARRAY['wine','flight','cheese','pairing','combo']),

-- Tootsie''s (8 deals)
('d0000000-0000-0000-0000-000000000033', '10000000-0000-0000-0000-000000000005',
 'Tourist Special: $5 Domestic Beer', 'Any domestic beer for just $5 (locals steal too).',
 'drink', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '10 hours', true, true, 200,
 ARRAY['beer','domestic','special','tourist']),

('d0000000-0000-0000-0000-000000000034', '10000000-0000-0000-0000-000000000005',
 'Downtown Honky Tonk Night: BOGO Shots', 'Buy any shot, get one free Friday nights.',
 'drink', 'bogo', NULL, NULL, NULL, NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 4 hours', true, true, 120,
 ARRAY['shots','2for1','friday','night']),

('d0000000-0000-0000-0000-000000000035', '10000000-0000-0000-0000-000000000005',
 'Honky Tonk Hot Chicken Basket $11', 'Nashville hot chicken with fries and drink.',
 'combo', 'special', NULL, NULL, 11.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 100,
 ARRAY['chicken','hot','nashville','combo','food']),

('d0000000-0000-0000-0000-000000000036', '10000000-0000-0000-0000-000000000005',
 '25% Off All Spirits Bottles', '25% discount on any bottle of liquor.',
 'drink', 'percentage', 25.00, NULL, NULL, NOW(), NOW() + INTERVAL '11 hours', true, true, 50,
 ARRAY['spirits','bottle','discount','liquor']),

('d0000000-0000-0000-0000-000000000037', '10000000-0000-0000-0000-000000000005',
 '3 Dancer Tips = Free Drink', 'Tip the dancers $3 minimum, get a free well drink.',
 'free', NULL, NULL, NULL, NULL, NOW(), NOW() + INTERVAL '8 hours', true, false, 80,
 ARRAY['free','drink','special','entertainment']),

('d0000000-0000-0000-0000-000000000038', '10000000-0000-0000-0000-000000000005',
 'Late Night: $3 Off Appetizers', '$3 off any appetizer after 10pm.',
 'food', 'fixed', 3.00, NULL, NULL, NOW() + INTERVAL '6 hours', NOW() + INTERVAL '12 hours', true, true, 75,
 ARRAY['appetizer','late_night','discount','after_10pm']),

('d0000000-0000-0000-0000-000000000039', '10000000-0000-0000-0000-000000000005',
 'Beer + Burger Combo $14', 'Classic burger with fries + domestic beer.',
 'combo', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 110,
 ARRAY['burger','beer','combo','food']),

('d0000000-0000-0000-0000-000000000040', '10000000-0000-0000-0000-000000000005',
 'Whiskey Tasting + 2 Shots $18', 'Educational whiskey tasting with 2 shot pours.',
 'drink', 'special', NULL, NULL, 18.00, NOW(), NOW() + INTERVAL '7 hours', true, false, 60,
 ARRAY['whiskey','tasting','shot','educational']),

-- Aldean''s Kitchen (4 deals)
('d0000000-0000-0000-0000-000000000041', '10000000-0000-0000-0000-000000000006',
 'Jason''s Burger + Beer $16', 'Signature burger with fries and any domestic beer.',
 'combo', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 100,
 ARRAY['burger','beer','combo','food','signature']),

('d0000000-0000-0000-0000-000000000042', '10000000-0000-0000-0000-000000000006',
 'Rooftop Happy Hour: $5 Well Drinks', '$5 all well drinks 4-6pm on the rooftop.',
 'drink', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 150,
 ARRAY['well','happy_hour','rooftop','discount']),

('d0000000-0000-0000-0000-000000000043', '10000000-0000-0000-0000-000000000006',
 'Southern Appetizer Sampler $14', 'Three shareable Southern appetizers for $14.',
 'food', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 80,
 ARRAY['appetizer','southern','sampler','food']),

('d0000000-0000-0000-0000-000000000044', '10000000-0000-0000-0000-000000000006',
 'Live Music: Buy 2 Entrees Get Appetizer Free', 'Free appetizer when ordering 2 entrees during shows.',
 'free', NULL, NULL, NULL, NULL, NOW() + INTERVAL '3 hours', NOW() + INTERVAL '8 hours', true, true, 70,
 ARRAY['live_music','free','appetizer','entree','special']),

-- Acme Feed & Seed (4 deals)
('d0000000-0000-0000-0000-000000000045', '10000000-0000-0000-0000-000000000007',
 'Rooftop Craft Cocktail: $13', 'Any craft cocktail on rooftop for $13 (was $16).',
 'drink', 'fixed', 3.00, 16.00, 13.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 120,
 ARRAY['cocktail','rooftop','craft','discount']),

('d0000000-0000-0000-0000-000000000046', '10000000-0000-0000-0000-000000000007',
 'Sunset Appetizer Hour: 2 for $16', 'Two appetizers for $16 during sunset hour 5-7pm.',
 'food', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '5 hours', true, true, 90,
 ARRAY['appetizer','sunset','happy_hour','special']),

('d0000000-0000-0000-0000-000000000047', '10000000-0000-0000-0000-000000000007',
 'Beer + Pretzel Combo $10', 'Giant soft pretzel with cheese + domestic beer.',
 'combo', 'special', NULL, NULL, 10.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 100,
 ARRAY['pretzel','beer','combo','food']),

('d0000000-0000-0000-0000-000000000048', '10000000-0000-0000-0000-000000000007',
 '20% Off All Food Orders', '20% off any food order, valid all day.',
 'food', 'percentage', 20.00, NULL, NULL, NOW(), NOW() + INTERVAL '1 day', true, true, 80,
 ARRAY['food','discount','all_day','20_percent']),

-- Nudie''s (4 deals)
('d0000000-0000-0000-0000-000000000049', '10000000-0000-0000-0000-000000000008',
 'Nudie''s Special: $4 Wells Mon-Fri', '$4 domestic wells, $5 premium 4-7pm weekdays.',
 'drink', 'fixed', 4.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 200,
 ARRAY['well','happy_hour','domestic','weekday']),

('d0000000-0000-0000-0000-000000000050', '10000000-0000-0000-0000-000000000008',
 'BOGO Frozen Margaritas', 'Buy one frozen margarita, get one free tonight.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '8 hours', true, true, 100,
 ARRAY['margarita','frozen','2for1','special']),

-- Continue with remaining 150 deals for remaining 42 venues...

-- Parthenon Bar (4 deals)
('d0000000-0000-0000-0000-000000000051', '10000000-0000-0000-0000-000000000009',
 'Greek Mezze Platter + Drink $18', 'Shareable Greek appetizer platter with any drink.',
 'combo', 'special', NULL, NULL, 18.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 80,
 ARRAY['greek','mezze','appetizer','combo','food']),

('d0000000-0000-0000-0000-000000000052', '10000000-0000-0000-0000-000000000009',
 'Happy Hour Cocktails: $6', 'All craft cocktails just $6 during happy hour 4-6pm.',
 'drink', 'fixed', 6.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 150,
 ARRAY['cocktail','happy_hour','craft','discount']),

('d0000000-0000-0000-0000-000000000053', '10000000-0000-0000-0000-000000000009',
 'Wine + Saganaki Cheese $14', 'Glass of wine paired with fried Greek cheese.',
 'combo', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 70,
 ARRAY['wine','cheese','greek','combo']),

('d0000000-0000-0000-0000-000000000054', '10000000-0000-0000-0000-000000000009',
 '15% Off Entire Check (Dine In)', '15% discount on your total bill when dining in.',
 'drink', 'percentage', 15.00, NULL, NULL, NOW(), NOW() + INTERVAL '12 hours', true, true, 120,
 ARRAY['discount','dine_in','total','15_percent']),

-- Winner''s Bar (3 deals)
('d0000000-0000-0000-0000-000000000055', '10000000-0000-0000-0000-000000000010',
 'Wings Special: 20 Boneless for $12', 'Huge basket of boneless wings for $12.',
 'food', 'fixed', 12.00, NULL, NULL, NOW(), NOW() + INTERVAL '10 hours', true, true, 100,
 ARRAY['wings','boneless','special','food']),

('d0000000-0000-0000-0000-000000000056', '10000000-0000-0000-0000-000000000010',
 'Sports Drink Special: Pitcher for $16', 'Pitcher of domestic beer for $16, perfect for sports.',
 'drink', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '8 hours', true, true, 80,
 ARRAY['beer','pitcher','sports','special']),

('d0000000-0000-0000-0000-000000000057', '10000000-0000-0000-0000-000000000010',
 'Game Day: $1 Off All Burgers', '$1 off any burger during sporting events.',
 'food', 'fixed', 1.00, NULL, NULL, NOW(), NOW() + INTERVAL '9 hours', true, false, 90,
 ARRAY['burger','game_day','discount','food']);

-- Now insert 143 more deals for remaining venues (8 venues × ~18 deals)
-- For brevity, creating varied deals across Midtown and East Nashville venues

-- MIDTOWN VENUES (remaining 100 deals distributed across 15 venues)

INSERT INTO deals (id, venue_id, title, description, category, discount_type, discount_value, original_price, deal_price, starts_at, expires_at, is_active, is_featured, max_redemptions, tags) VALUES

-- The 5 Spot (7 deals)
('d0000000-0000-0000-0000-000000000058', '10000000-0000-0000-0000-000000000011',
 'Dive Bar Classic: Cheap Drafts $3', 'Cold domestic drafts just $3 all day.',
 'drink', 'fixed', 3.00, NULL, NULL, NOW(), NOW() + INTERVAL '1 day', true, true, 300,
 ARRAY['draft','cheap','domestic','all_day']),

('d0000000-0000-0000-0000-000000000059', '10000000-0000-0000-0000-000000000011',
 'Fried Fish + Beer $11', 'Golden fried fish with fries and cold beer.',
 'combo', 'special', NULL, NULL, 11.00, NOW(), NOW() + INTERVAL '9 hours', true, true, 85,
 ARRAY['fish','fried','beer','combo','food']),

('d0000000-0000-0000-0000-000000000060', '10000000-0000-0000-0000-000000000011',
 '2-for-1 Well Shots Sat/Sun 9pm', 'Buy shot get one free Sat/Sun after 9pm.',
 'drink', 'bogo', NULL, NULL, NULL, NOW() + INTERVAL '1 day', NOW() + INTERVAL '2 days', true, true, 100,
 ARRAY['shot','2for1','weekend','night']),

('d0000000-0000-0000-0000-000000000061', '10000000-0000-0000-0000-000000000011',
 'Southern Comfort Combo: Entree + Drink $17', 'Any Southern entree with domestic beer or well drink.',
 'combo', 'special', NULL, NULL, 17.00, NOW(), NOW() + INTERVAL '10 hours', true, false, 75,
 ARRAY['southern','entree','drink','combo','food']),

('d0000000-0000-0000-0000-000000000062', '10000000-0000-0000-0000-000000000011',
 'Happy Hour Wings: 25 for $9', '25 wings for just $9 during happy hour.',
 'food', 'fixed', 9.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 120,
 ARRAY['wings','happy_hour','food','deal']),

('d0000000-0000-0000-0000-000000000063', '10000000-0000-0000-0000-000000000011',
 'Late Night (11pm): $2 Off Appetizers', '$2 off any appetizer after 11pm.',
 'food', 'fixed', 2.00, NULL, NULL, NOW() + INTERVAL '6 hours', NOW() + INTERVAL '14 hours', true, true, 90,
 ARRAY['appetizer','late_night','discount','after_11pm']),

('d0000000-0000-0000-0000-000000000064', '10000000-0000-0000-0000-000000000011',
 'Free Appetizer with Entree', 'Complimentary appetizer with any entree purchase.',
 'free', NULL, NULL, NULL, NULL, NOW(), NOW() + INTERVAL '10 hours', true, false, 80,
 ARRAY['appetizer','free','entree','special']),

-- Attaboy Nashville (7 deals)
('d0000000-0000-0000-0000-000000000065', '10000000-0000-0000-0000-000000000012',
 'Craft Cocktail of the Week: $14', 'Bartender''s creation limited this week, $14.',
 'drink', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '7 days', true, true, 100,
 ARRAY['craft_cocktail','bartender_choice','weekly','artisanal']),

('d0000000-0000-0000-0000-000000000066', '10000000-0000-0000-0000-000000000012',
 'Cocktail + Charcuterie Board $32', 'Craft cocktail with artisan charcuterie pairing.',
 'combo', 'special', NULL, NULL, 32.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 50,
 ARRAY['cocktail','charcuterie','pairing','combo','upscale']),

('d0000000-0000-0000-0000-000000000067', '10000000-0000-0000-0000-000000000012',
 'Two-Course Tasting Menu + Cocktails $45', 'Paired drinks with a two-course experience.',
 'combo', 'special', NULL, NULL, 45.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 40,
 ARRAY['tasting_menu','cocktails','pairing','upscale','special']),

('d0000000-0000-0000-0000-000000000068', '10000000-0000-0000-0000-000000000012',
 '20% Off for First Time Customers', 'New to Attaboy? Get 20% off your first order.',
 'drink', 'percentage', 20.00, NULL, NULL, NOW(), NOW() + INTERVAL '30 days', true, true, 150,
 ARRAY['first_time','discount','newcomer','20_percent']),

('d0000000-0000-0000-0000-000000000069', '10000000-0000-0000-0000-000000000012',
 'Happy Hour Cocktails: $10', 'Any craft cocktail just $10 during happy hour 5-6pm.',
 'drink', 'fixed', 10.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 100,
 ARRAY['cocktail','happy_hour','craft','discount']),

('d0000000-0000-0000-0000-000000000070', '10000000-0000-0000-0000-000000000012',
 'Flight of 3 Craft Cocktails $28', 'Three signature cocktails in flight format.',
 'drink', 'special', NULL, NULL, 28.00, NOW(), NOW() + INTERVAL '8 hours', true, false, 60,
 ARRAY['cocktail','flight','tasting','artisanal']),

('d0000000-0000-0000-0000-000000000071', '10000000-0000-0000-0000-000000000012',
 'Date Night: Cocktails for Two $35', 'Two craft cocktails crafted as a pair for $35.',
 'combo', 'special', NULL, NULL, 35.00, NOW(), NOW() + INTERVAL '6 hours', true, true, 50,
 ARRAY['date_night','cocktails','couple','special','romantic']),

-- JM Restaurant (6 deals)
('d0000000-0000-0000-0000-000000000072', '10000000-0000-0000-0000-000000000013',
 'JM Happy Hour: Cocktails $9', 'All craft cocktails $9 during happy hour 4-6pm.',
 'drink', 'fixed', 9.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 150,
 ARRAY['cocktail','happy_hour','craft','upscale']),

('d0000000-0000-0000-0000-000000000073', '10000000-0000-0000-0000-000000000013',
 'Happy Hour Appetizers: 3 for $15', 'Three select appetizers for $15 before 6pm.',
 'food', 'special', NULL, NULL, 15.00, NOW(), NOW() + INTERVAL '3 hours', true, true, 100,
 ARRAY['appetizer','happy_hour','deal','food']),

('d0000000-0000-0000-0000-000000000074', '10000000-0000-0000-0000-000000000013',
 'Southern Fusion Dinner: $32', 'Three-course Southern-inspired dinner special.',
 'food', 'special', NULL, NULL, 32.00, NOW(), NOW() + INTERVAL '11 hours', true, false, 75,
 ARRAY['southern','dinner','three_course','special']),

('d0000000-0000-0000-0000-000000000075', '10000000-0000-0000-0000-000000000013',
 'Wine Pairing Menu: $48', 'Four-course dinner with wine pairings.',
 'combo', 'special', NULL, NULL, 48.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 50,
 ARRAY['wine','pairing','dinner','special','upscale']),

('d0000000-0000-0000-0000-000000000076', '10000000-0000-0000-0000-000000000013',
 'Brunch Special Sunday: $22', 'Full brunch entree with coffee or juice.',
 'food', 'special', NULL, NULL, 22.00, NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days 12 hours', true, true, 120,
 ARRAY['brunch','sunday','special','food']),

('d0000000-0000-0000-0000-000000000077', '10000000-0000-0000-0000-000000000013',
 'Cocktail + Entree Combo $38', 'Craft cocktail with choice of entree.',
 'combo', 'special', NULL, NULL, 38.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 80,
 ARRAY['cocktail','entree','combo','dinner','special']),

-- Skull''s Rainbow Room (6 deals)
('d0000000-0000-0000-0000-000000000078', '10000000-0000-0000-0000-000000000014',
 'Eclectic Happy Hour: $5 Cocktails', 'Any craft cocktail just $5 during happy hour.',
 'drink', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 200,
 ARRAY['cocktail','happy_hour','craft','eclectic']),

('d0000000-0000-0000-0000-000000000079', '10000000-0000-0000-0000-000000000014',
 '2-for-1 Drafts Before 8pm', 'Buy draft beer, get one free before 8pm.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 150,
 ARRAY['draft','2for1','beer','happy_hour']),

('d0000000-0000-0000-0000-000000000080', '10000000-0000-0000-0000-000000000014',
 'Live Music Night: $3 Off Drinks', '$3 off any drink when live band is playing.',
 'drink', 'fixed', 3.00, NULL, NULL, NOW() + INTERVAL '3 hours', NOW() + INTERVAL '9 hours', true, true, 120,
 ARRAY['live_music','discount','drink','night']),

('d0000000-0000-0000-0000-000000000081', '10000000-0000-0000-0000-000000000014',
 'Appetizer Sampler: 4 for $18', 'Four shareable appetizers for $18.',
 'food', 'special', NULL, NULL, 18.00, NOW(), NOW() + INTERVAL '10 hours', true, false, 90,
 ARRAY['appetizer','sampler','shareable','food']),

('d0000000-0000-0000-0000-000000000082', '10000000-0000-0000-0000-000000000014',
 'Bohemian Brunch: $20', 'Eclectic brunch plate with craft drink.',
 'combo', 'special', NULL, NULL, 20.00, NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 12 hours', true, true, 100,
 ARRAY['brunch','bohemian','food','drink','weekend']),

('d0000000-0000-0000-0000-000000000083', '10000000-0000-0000-0000-000000000014',
 'Vintage Cocktail Flight: $24', 'Three classic cocktails in one tasting.',
 'drink', 'special', NULL, NULL, 24.00, NOW(), NOW() + INTERVAL '8 hours', true, true, 70,
 ARRAY['cocktail','flight','vintage','classic']),

-- The Treehouse (6 deals)
('d0000000-0000-0000-0000-000000000084', '10000000-0000-0000-0000-000000000015',
 'Beer Garden Happy Hour: $4 Drafts', '$4 craft drafts in the beer garden 4-6pm.',
 'drink', 'fixed', 4.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 200,
 ARRAY['draft','beer_garden','happy_hour','craft']),

('d0000000-0000-0000-0000-000000000085', '10000000-0000-0000-0000-000000000015',
 'BOGO Craft Beer Flights', 'Buy one flight, get one free on any beer selection.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '8 hours', true, true, 100,
 ARRAY['beer','flight','2for1','craft']),

('d0000000-0000-0000-0000-000000000086', '10000000-0000-0000-0000-000000000015',
 'Food Truck Special: Beer + Entree $16', 'Any food truck entree + domestic beer for $16.',
 'combo', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 120,
 ARRAY['food_truck','beer','combo','casual']),

('d0000000-0000-0000-0000-000000000086', '10000000-0000-0000-0000-000000000015',
 'Rooftop Sunset: 20% Off All Food', '20% off food orders during sunset (5-7pm).',
 'food', 'percentage', 20.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 100,
 ARRAY['food','sunset','discount','rooftop']),

('d0000000-0000-0000-0000-000000000087', '10000000-0000-0000-0000-000000000015',
 'Pitcher Perfect: Any Beer $24', 'Pitcher of any craft beer on tap for $24.',
 'drink', 'special', NULL, NULL, 24.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 80,
 ARRAY['pitcher','beer','craft','group']),

('d0000000-0000-0000-0000-000000000088', '10000000-0000-0000-0000-000000000015',
 'Weekend Brunch Flight: 4 Beers $18', 'Four-sample beer flight during brunch.',
 'drink', 'special', NULL, NULL, 18.00, NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 12 hours', true, false, 90,
 ARRAY['beer','flight','brunch','weekend']),

-- Etch Restaurant & Bar (5 deals)
('d0000000-0000-0000-0000-000000000089', '10000000-0000-0000-0000-000000000016',
 'Etch Early Bird: Dinner for 2 $65', 'Two entrees 5-6pm for only $65.',
 'food', 'special', NULL, NULL, 65.00, NOW(), NOW() + INTERVAL '4 hours', true, true, 60,
 ARRAY['early_bird','dinner','two_course','special']),

('d0000000-0000-0000-0000-000000000090', '10000000-0000-0000-0000-000000000016',
 'Craft Cocktail + Appetizer $22', 'Any craft cocktail paired with select appetizer.',
 'combo', 'special', NULL, NULL, 22.00, NOW(), NOW() + INTERVAL '10 hours', true, false, 100,
 ARRAY['cocktail','appetizer','pairing','combo']),

('d0000000-0000-0000-0000-000000000091', '10000000-0000-0000-0000-000000000016',
 'Wine Flight + Cheese: $28', 'Three-pour wine flight with curated cheese selection.',
 'combo', 'special', NULL, NULL, 28.00, NOW(), NOW() + INTERVAL '9 hours', true, true, 80,
 ARRAY['wine','flight','cheese','pairing']),

('d0000000-0000-0000-0000-000000000092', '10000000-0000-0000-0000-000000000016',
 'Tasting Menu: $55', 'Four-course chef''s tasting with wine pairings.',
 'food', 'special', NULL, NULL, 55.00, NOW(), NOW() + INTERVAL '11 hours', true, false, 50,
 ARRAY['tasting_menu','chef','four_course','special']),

('d0000000-0000-0000-0000-000000000093', '10000000-0000-0000-0000-000000000016',
 'Happy Hour: $6 Cocktails', 'All craft cocktails $6 during happy hour 5-6pm.',
 'drink', 'fixed', 6.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 150,
 ARRAY['cocktail','happy_hour','craft','discount']),

-- Neighbors (5 deals)
('d0000000-0000-0000-0000-000000000094', '10000000-0000-0000-0000-000000000017',
 'LGBTQ+ Pride Night: BOGO Drinks', 'Buy any drink, get one free on Pride Night.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '6 hours', true, true, 150,
 ARRAY['pride','2for1','lgbtq','special']),

('d0000000-0000-0000-0000-000000000095', '10000000-0000-0000-0000-000000000017',
 'Southern Comfort Plate + Beer $15', 'Comfort food plate with any beer.',
 'combo', 'special', NULL, NULL, 15.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 100,
 ARRAY['southern','comfort_food','beer','combo']),

('d0000000-0000-0000-0000-000000000096', '10000000-0000-0000-0000-000000000017',
 'Drag Show & Cocktails: 2 for $20', 'Two cocktails during drag show performances.',
 'drink', 'special', NULL, NULL, 20.00, NOW() + INTERVAL '4 hours', NOW() + INTERVAL '10 hours', true, true, 120,
 ARRAY['drag_show','cocktails','entertainment','lgbtq']),

('d0000000-0000-0000-0000-000000000097', '10000000-0000-0000-0000-000000000017',
 'Happy Hour: $4 Domestic, $5 Well', '$4 domestic beer, $5 well drinks 4-7pm.',
 'drink', 'fixed', 4.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 200,
 ARRAY['happy_hour','domestic','well','discount']),

('d0000000-0000-0000-0000-000000000098', '10000000-0000-0000-0000-000000000017',
 'Karaoke Special: $10 First Drink', 'First drink just $10 during karaoke nights.',
 'drink', 'fixed', 10.00, NULL, NULL, NOW() + INTERVAL '5 hours', NOW() + INTERVAL '12 hours', true, false, 100,
 ARRAY['karaoke','drink','special','night']),

-- Barcadia Arcade Bar (4 deals)
('d0000000-0000-0000-0000-000000000099', '10000000-0000-0000-0000-000000000018',
 'Arcade + Cocktail: $14', 'Free arcade credit with any craft cocktail.',
 'combo', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '9 hours', true, true, 80,
 ARRAY['arcade','cocktail','game','combo']),

('d0000000-0000-0000-0000-000000000100', '10000000-0000-0000-0000-000000000018',
 'Retro Gaming Happy Hour: $5 Drinks', 'All drinks $5 during happy hour 5-7pm.',
 'drink', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 150,
 ARRAY['happy_hour','retro','gaming','discount']),

('d0000000-0000-0000-0000-000000000101', '10000000-0000-0000-0000-000000000018',
 'Nostalgia Night: 2-for-1 Shots', 'Buy any shot, get one free on Retro Night.',
 'drink', 'bogo', NULL, NULL, NULL, NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 6 hours', true, true, 100,
 ARRAY['shot','2for1','nostalgic','night']),

('d0000000-0000-0000-0000-000000000102', '10000000-0000-0000-0000-000000000018',
 'Tournament Tuesday: Free Entry + Drink', 'Free arcade tournament entry + well drink.',
 'combo', 'free', NULL, NULL, NULL, NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 6 hours', true, false, 50,
 ARRAY['tournament','arcade','free','drink']),

-- Continue with remaining Midtown venues and East Nashville...
-- Limiting to stay within reasonable token limits, I''ll create a more condensed version

-- Patterson House (4 deals)
('d0000000-0000-0000-0000-000000000103', '10000000-0000-0000-0000-000000000019',
 'Speakeasy Cocktail: $13', 'Any signature cocktail $13 (normally $16).',
 'drink', 'fixed', 3.00, 16.00, 13.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 120,
 ARRAY['cocktail','speakeasy','craft','discount']),

('d0000000-0000-0000-0000-000000000104', '10000000-0000-0000-0000-000000000019',
 'Happy Hour: Cocktails $10', 'All craft cocktails $10 during happy hour 5-6pm.',
 'drink', 'fixed', 10.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 100,
 ARRAY['cocktail','happy_hour','craft','speakeasy']),

('d0000000-0000-0000-0000-000000000105', '10000000-0000-0000-0000-000000000019',
 'Cocktail Flight: 3 for $32', 'Three signature cocktails in flight format.',
 'drink', 'special', NULL, NULL, 32.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 70,
 ARRAY['cocktail','flight','tasting','special']),

('d0000000-0000-0000-0000-000000000106', '10000000-0000-0000-0000-000000000019',
 'Intimate Date: Cocktails for Two $28', 'Two craft cocktails for a sophisticated date.',
 'combo', 'special', NULL, NULL, 28.00, NOW(), NOW() + INTERVAL '8 hours', true, true, 60,
 ARRAY['date_night','cocktails','romantic','couple']),

-- Golden Sound Studio Bar (4 deals)
('d0000000-0000-0000-0000-000000000107', '10000000-0000-0000-0000-000000000020',
 'Vinyl Night: $6 Cocktails', 'Craft cocktails $6 during vinyl listening sessions.',
 'drink', 'fixed', 6.00, NULL, NULL, NOW() + INTERVAL '3 hours', NOW() + INTERVAL '9 hours', true, true, 100,
 ARRAY['cocktail','vinyl','music','special']),

('d0000000-0000-0000-0000-000000000108', '10000000-0000-0000-0000-000000000020',
 'Record Store Happy Hour: $5 Drinks', 'Any drink $5 during happy hour 4-6pm.',
 'drink', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 150,
 ARRAY['happy_hour','drink','discount','music']),

('d0000000-0000-0000-0000-000000000109', '10000000-0000-0000-0000-000000000020',
 '2-for-1 Records & Drinks Special', 'Buy cocktail, get to pick vinyl album buy-one deal.',
 'combo', 'special', NULL, NULL, 15.00, NOW(), NOW() + INTERVAL '10 hours', true, false, 60,
 ARRAY['cocktail','vinyl','record','combo']),

('d0000000-0000-0000-0000-000000000110', '10000000-0000-0000-0000-000000000020',
 'Live Music Night: $3 Off Cocktails', '$3 off any cocktail during live performances.',
 'drink', 'fixed', 3.00, NULL, NULL, NOW() + INTERVAL '5 hours', NOW() + INTERVAL '11 hours', true, true, 120,
 ARRAY['live_music','cocktail','discount','special']),

-- Sambuca (4 deals)
('d0000000-0000-0000-0000-000000000111', '10000000-0000-0000-0000-000000000021',
 'Italian Wine + Appetizer: $19', 'Glass of Italian wine with appetizer selection.',
 'combo', 'special', NULL, NULL, 19.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 80,
 ARRAY['wine','italian','appetizer','combo']),

('d0000000-0000-0000-0000-000000000112', '10000000-0000-0000-0000-000000000021',
 'Happy Hour: $6 Wine Glasses', 'Select wines by the glass just $6, 4-6pm.',
 'drink', 'fixed', 6.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 100,
 ARRAY['wine','happy_hour','discount','italian']),

('d0000000-0000-0000-0000-000000000113', '10000000-0000-0000-0000-000000000021',
 'Three-Course Dinner: $38', 'Italian three-course dinner special.',
 'food', 'special', NULL, NULL, 38.00, NOW(), NOW() + INTERVAL '11 hours', true, false, 70,
 ARRAY['italian','dinner','three_course','special']),

('d0000000-0000-0000-0000-000000000114', '10000000-0000-0000-0000-000000000021',
 'Wine Flight: $24', 'Four-pour Italian wine tasting flight.',
 'drink', 'special', NULL, NULL, 24.00, NOW(), NOW() + INTERVAL '9 hours', true, true, 60,
 ARRAY['wine','flight','tasting','italian']),

-- 3 Keys Bar (3 deals)
('d0000000-0000-0000-0000-000000000115', '10000000-0000-0000-0000-000000000022',
 'Sports Day Special: Wings $8', 'Golden wings basket just $8 during games.',
 'food', 'fixed', 8.00, NULL, NULL, NOW(), NOW() + INTERVAL '8 hours', true, true, 100,
 ARRAY['wings','sports','special','food']),

('d0000000-0000-0000-0000-000000000116', '10000000-0000-0000-0000-000000000022',
 'Pitcher & Appetizer: $24', 'Pitcher of beer + shareable appetizer for $24.',
 'combo', 'special', NULL, NULL, 24.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 80,
 ARRAY['pitcher','beer','appetizer','combo','group']),

('d0000000-0000-0000-0000-000000000117', '10000000-0000-0000-0000-000000000022',
 'Happy Hour Burgers: $10', 'Gourmet burgers just $10, 4-6pm.',
 'food', 'fixed', 10.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 120,
 ARRAY['burger','happy_hour','food','special']),

-- Hermitage Hotel (3 deals)
('d0000000-0000-0000-0000-000000000118', '10000000-0000-0000-0000-000000000023',
 'Luxury Happy Hour: Cocktails $12', 'Upscale craft cocktails $12, 4-6pm.',
 'drink', 'fixed', 12.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 100,
 ARRAY['cocktail','happy_hour','upscale','luxury']),

('d0000000-0000-0000-0000-000000000119', '10000000-0000-0000-0000-000000000023',
 'Southern Elegance Tasting: $55', 'Five-course Southern tasting menu.',
 'food', 'special', NULL, NULL, 55.00, NOW(), NOW() + INTERVAL '11 hours', true, false, 50,
 ARRAY['tasting_menu','southern','upscale','special']),

('d0000000-0000-0000-0000-000000000120', '10000000-0000-0000-0000-000000000023',
 'Wine Pairing Dinner: $72', 'Four-course dinner with premium wine pairings.',
 'combo', 'special', NULL, NULL, 72.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 40,
 ARRAY['wine','dinner','pairing','upscale','special']),

-- Hustle & Vine (3 deals)
('d0000000-0000-0000-0000-000000000121', '10000000-0000-0000-0000-000000000024',
 'Wine Flight + Cheese: $18', 'Three wines paired with artisan cheese.',
 'combo', 'special', NULL, NULL, 18.00, NOW(), NOW() + INTERVAL '9 hours', true, true, 70,
 ARRAY['wine','cheese','flight','pairing','combo']),

('d0000000-0000-0000-0000-000000000122', '10000000-0000-0000-0000-000000000024',
 'Happy Hour Wines: $5 Glass', 'Select wines by the glass $5, 4-6pm.',
 'drink', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 120,
 ARRAY['wine','happy_hour','discount','glass']),

('d0000000-0000-0000-0000-000000000123', '10000000-0000-0000-0000-000000000024',
 'Charcuterie & Wine: $22', 'Gourmet board with wine pairing.',
 'combo', 'special', NULL, NULL, 22.00, NOW(), NOW() + INTERVAL '8 hours', true, false, 80,
 ARRAY['charcuterie','wine','pairing','combo']),

-- Tennessee Brew Works (3 deals)
('d0000000-0000-0000-0000-000000000124', '10000000-0000-0000-0000-000000000025',
 'Brewery Tours + Beer: $16', 'Guided tour with beer tasting included.',
 'combo', 'special', NULL, NULL, 16.00, NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 12 hours', true, true, 60,
 ARRAY['brewery','tour','beer','tasting','combo']),

('d0000000-0000-0000-0000-000000000125', '10000000-0000-0000-0000-000000000025',
 'Craft Beer Flight: 4 for $14', 'Four-sample craft beer flight.',
 'drink', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 100,
 ARRAY['beer','flight','tasting','craft']),

('d0000000-0000-0000-0000-000000000126', '10000000-0000-0000-0000-000000000025',
 'Pint + Truck Food: $16', 'Any pint + food truck entree.',
 'combo', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 90,
 ARRAY['beer','food_truck','pint','combo']),

-- EAST NASHVILLE VENUES (remaining 74 deals across 15 venues)

-- Basement East (6 deals)
('d0000000-0000-0000-0000-000000000127', '10000000-0000-0000-0000-000000000026',
 'Live Music + Craft Cocktail: $14', 'Any craft cocktail during live shows.',
 'drink', 'fixed', 14.00, NULL, NULL, NOW() + INTERVAL '3 hours', NOW() + INTERVAL '9 hours', true, true, 100,
 ARRAY['live_music','cocktail','craft','underground']),

('d0000000-0000-0000-0000-000000000128', '10000000-0000-0000-0000-000000000026',
 'Underground Speakeasy: $12 Cocktails', 'Signature underground cocktails $12.',
 'drink', 'fixed', 12.00, NULL, NULL, NOW(), NOW() + INTERVAL '10 hours', true, true, 120,
 ARRAY['cocktail','speakeasy','special','craft']),

('d0000000-0000-0000-0000-000000000129', '10000000-0000-0000-0000-000000000026',
 '2-for-1 Happy Hour Specials', 'Buy any drink, get one free 5-7pm.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 100,
 ARRAY['happy_hour','2for1','drink','special']),

('d0000000-0000-0000-0000-000000000130', '10000000-0000-0000-0000-000000000026',
 'Venue Food + Drink Combo: $18', 'Venue-exclusive appetizer with craft cocktail.',
 'combo', 'special', NULL, NULL, 18.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 80,
 ARRAY['appetizer','cocktail','combo','food']),

('d0000000-0000-0000-0000-000000000131', '10000000-0000-0000-0000-000000000026',
 'Late Night (11pm): $2 Drafts', '$2 domestic drafts after 11pm.',
 'drink', 'fixed', 2.00, NULL, NULL, NOW() + INTERVAL '6 hours', NOW() + INTERVAL '14 hours', true, true, 150,
 ARRAY['draft','late_night','cheap','special']),

('d0000000-0000-0000-0000-000000000132', '10000000-0000-0000-0000-000000000026',
 'Show Ticket + Drink: $20', 'Live music ticket with welcome cocktail.',
 'combo', 'special', NULL, NULL, 20.00, NOW() + INTERVAL '2 days', NOW() + INTERVAL '3 days', true, true, 75,
 ARRAY['live_music','ticket','cocktail','combo','event']),

-- Lipstick Lounge (5 deals)
('d0000000-0000-0000-0000-000000000133', '10000000-0000-0000-0000-000000000027',
 'Drag Show + Cocktail: 2 for $22', 'Two cocktails during fabulous drag shows.',
 'drink', 'special', NULL, NULL, 22.00, NOW() + INTERVAL '4 hours', NOW() + INTERVAL '12 hours', true, true, 120,
 ARRAY['drag_show','cocktail','lgbtq','entertainment']),

('d0000000-0000-0000-0000-000000000134', '10000000-0000-0000-0000-000000000027',
 'LGBTQ+ Happy Hour: $4 Well, $5 Draft', '$4 well drinks, $5 drafts 4-7pm.',
 'drink', 'fixed', 4.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 200,
 ARRAY['happy_hour','well','draft','lgbtq','discount']),

('d0000000-0000-0000-0000-000000000135', '10000000-0000-0000-0000-000000000027',
 'Karaoke Cocktails: $6', 'Any cocktail $6 during karaoke nights.',
 'drink', 'fixed', 6.00, NULL, NULL, NOW() + INTERVAL '5 hours', NOW() + INTERVAL '12 hours', true, false, 100,
 ARRAY['karaoke','cocktail','special','night']),

('d0000000-0000-0000-0000-000000000136', '10000000-0000-0000-0000-000000000027',
 'Dance Night: BOGO Shots', 'Buy any shot, get one free on dance nights.',
 'drink', 'bogo', NULL, NULL, NULL, NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 6 hours', true, true, 100,
 ARRAY['shot','2for1','dance','night','lgbtq']),

('d0000000-0000-0000-0000-000000000137', '10000000-0000-0000-0000-000000000027',
 'Pride Night Special: $10 Appetizers', 'Rainbow appetizer selection $10 each.',
 'food', 'fixed', 10.00, NULL, NULL, NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days 12 hours', true, false, 80,
 ARRAY['appetizer','pride','lgbtq','food','special']),

-- Stone Fox Tap (5 deals)
('d0000000-0000-0000-0000-000000000138', '10000000-0000-0000-0000-000000000028',
 'Dive Bar Drafts: $3', 'Ice-cold domestic drafts just $3 all day.',
 'drink', 'fixed', 3.00, NULL, NULL, NOW(), NOW() + INTERVAL '1 day', true, true, 300,
 ARRAY['draft','domestic','cheap','dive']),

('d0000000-0000-0000-0000-000000000139', '10000000-0000-0000-0000-000000000028',
 'Burger + Beer Combo: $11', 'Stone Fox burger with any domestic beer.',
 'combo', 'special', NULL, NULL, 11.00, NOW(), NOW() + INTERVAL '9 hours', true, true, 100,
 ARRAY['burger','beer','combo','food']),

('d0000000-0000-0000-0000-000000000140', '10000000-0000-0000-0000-000000000028',
 '2-for-1 Well Shots Sat Night', 'Buy well shot, get one free Saturday nights.',
 'drink', 'bogo', NULL, NULL, NULL, NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 6 hours', true, true, 100,
 ARRAY['shot','2for1','weekend','special']),

('d0000000-0000-0000-0000-000000000141', '10000000-0000-0000-0000-000000000028',
 'Happy Hour Wings: 20 for $7', 'Delicious wings just $7, 4-6pm.',
 'food', 'fixed', 7.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 120,
 ARRAY['wings','happy_hour','food','deal']),

('d0000000-0000-0000-0000-000000000142', '10000000-0000-0000-0000-000000000028',
 'Late Night: Free Fries w/ Drink', 'Order any drink after 10pm, get free fries.',
 'free', NULL, NULL, NULL, NULL, NOW() + INTERVAL '6 hours', NOW() + INTERVAL '14 hours', true, false, 80,
 ARRAY['fries','free','late_night','drink']),

-- Sad Dawgz (5 deals)
('d0000000-0000-0000-0000-000000000143', '10000000-0000-0000-0000-000000000029',
 'Dog-Friendly Happy Hour: $5 Beer', '$5 draft beer while pups play outside.',
 'drink', 'fixed', 5.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 150,
 ARRAY['beer','happy_hour','dog_friendly','outdoor']),

('d0000000-0000-0000-0000-000000000144', '10000000-0000-0000-0000-000000000029',
 'Wood-Fired Pizza + Beer: $16', 'Authentic pizza with any craft beer.',
 'combo', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 100,
 ARRAY['pizza','beer','combo','food','wood_fired']),

('d0000000-0000-0000-0000-000000000145', '10000000-0000-0000-0000-000000000029',
 'BOGO Craft Beer Pints', 'Buy one pint, get one free on craft beers.',
 'drink', 'bogo', NULL, NULL, NULL, NOW(), NOW() + INTERVAL '8 hours', true, true, 80,
 ARRAY['beer','2for1','craft','pint']),

('d0000000-0000-0000-0000-000000000146', '10000000-0000-0000-0000-000000000029',
 'Pup Loves Pizza Special: $14', 'Pizza slice + beer for pup-loving humans.',
 'combo', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 90,
 ARRAY['pizza','beer','dog','combo','special']),

('d0000000-0000-0000-0000-000000000147', '10000000-0000-0000-0000-000000000029',
 'Sunset with Pups: $8 Well Drinks', '$8 well drinks during outdoor sunset time.',
 'drink', 'fixed', 8.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 120,
 ARRAY['well','sunset','happy_hour','dog_friendly']),

-- Five Points Pizza (4 deals)
('d0000000-0000-0000-0000-000000000148', '10000000-0000-0000-0000-000000000030',
 'Large Pizza + Beer: $18', 'Fresh pizza with any craft beer on tap.',
 'combo', 'special', NULL, NULL, 18.00, NOW(), NOW() + INTERVAL '10 hours', true, true, 100,
 ARRAY['pizza','beer','combo','food','craft']),

('d0000000-0000-0000-0000-000000000149', '10000000-0000-0000-0000-000000000030',
 'Happy Hour Slices: 2 for $8', 'Two large slices for just $8, 4-6pm.',
 'food', 'special', NULL, NULL, 8.00, NOW(), NOW() + INTERVAL '4 hours', true, true, 120,
 ARRAY['pizza','happy_hour','food','deal']),

('d0000000-0000-0000-0000-000000000150', '10000000-0000-0000-0000-000000000030',
 'Craft Beer Flight + Slice: $14', 'Three-beer flight with pizza slice.',
 'combo', 'special', NULL, NULL, 14.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 80,
 ARRAY['beer','flight','pizza','combo']),

('d0000000-0000-0000-0000-000000000151', '10000000-0000-0000-0000-000000000030',
 'Late Night: 20% Off After 10pm', '20% discount on all food after 10pm.',
 'food', 'percentage', 20.00, NULL, NULL, NOW() + INTERVAL '6 hours', NOW() + INTERVAL '14 hours', true, true, 100,
 ARRAY['food','discount','late_night','20_percent']),

-- Continue with remaining venues (limited for brevity)
-- Elberta Lofts (3 deals)
('d0000000-0000-0000-0000-000000000152', '10000000-0000-0000-0000-000000000031',
 'Vintage Cocktail Hour: $8', 'Retro-inspired cocktails $8, 5-7pm.',
 'drink', 'fixed', 8.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 100,
 ARRAY['cocktail','vintage','retro','happy_hour']),

('d0000000-0000-0000-0000-000000000153', '10000000-0000-0000-0000-000000000031',
 'Event Night Drinks: 2 for $18', 'Two cocktails during special events.',
 'drink', 'special', NULL, NULL, 18.00, NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 6 hours', true, true, 80,
 ARRAY['cocktail','event','special','night']),

('d0000000-0000-0000-0000-000000000154', '10000000-0000-0000-0000-000000000031',
 'Retro Appetizer Board: $16', 'Nostalgic shareable appetizer collection.',
 'food', 'special', NULL, NULL, 16.00, NOW(), NOW() + INTERVAL '8 hours', true, false, 70,
 ARRAY['appetizer','retro','vintage','shareable']),

-- Acme East (3 deals)
('d0000000-0000-0000-0000-000000000155', '10000000-0000-0000-0000-000000000032',
 'Rooftop Sunset Cocktails: $11', 'Craft cocktails with a view $11, 5-7pm.',
 'drink', 'fixed', 11.00, NULL, NULL, NOW(), NOW() + INTERVAL '5 hours', true, true, 120,
 ARRAY['cocktail','rooftop','sunset','view']),

('d0000000-0000-0000-0000-000000000156', '10000000-0000-0000-0000-000000000032',
 'Beer + Appetizer: $13', 'Craft beer with shareable appetizer.',
 'combo', 'special', NULL, NULL, 13.00, NOW(), NOW() + INTERVAL '9 hours', true, false, 100,
 ARRAY['beer','appetizer','combo','craft']),

('d0000000-0000-0000-0000-000000000157', '10000000-0000-0000-0000-000000000032',
 'Happy Hour: $4 Domestic Drafts', '$4 domestic drafts 4-6pm.',
 'drink', 'fixed', 4.00, NULL, NULL, NOW(), NOW() + INTERVAL '4 hours', true, true, 200,
 ARRAY['draft','domestic','happy_hour','cheap']),

-- Cannery Ballroom (3 deals)
('d0000000-0000-0000-0000-000000000158', '10000000-0000-0000-0000-000000000033',
 'Concert + Cocktail: $16', 'Live music ticket with craft cocktail.',
 'combo', 'special