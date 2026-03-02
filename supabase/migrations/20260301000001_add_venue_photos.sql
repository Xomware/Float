-- Venue photos for gallery display
CREATE TABLE venue_photos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id uuid REFERENCES venues(id) ON DELETE CASCADE,
    url text NOT NULL,
    caption text,
    sort_order integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

-- Index for fast lookup by venue
CREATE INDEX idx_venue_photos_venue_id ON venue_photos(venue_id);

-- RLS
ALTER TABLE venue_photos ENABLE ROW LEVEL SECURITY;

-- Anyone can read venue photos
CREATE POLICY "venue_photos_read_all" ON venue_photos
    FOR SELECT USING (true);

-- Only authenticated users (merchants) can manage photos
CREATE POLICY "venue_photos_insert_auth" ON venue_photos
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "venue_photos_delete_auth" ON venue_photos
    FOR DELETE USING (auth.role() = 'authenticated');
