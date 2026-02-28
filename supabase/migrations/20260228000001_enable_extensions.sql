-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;        -- fuzzy text search
CREATE EXTENSION IF NOT EXISTS unaccent;        -- accent-insensitive search
CREATE EXTENSION IF NOT EXISTS pg_stat_statements; -- query performance

-- Verify PostGIS version
DO $$
BEGIN
  RAISE NOTICE 'PostGIS version: %', PostGIS_Version();
END $$;
