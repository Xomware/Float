# Float Merchant Portal

A Next.js 15 dashboard for Float merchants to manage venues, deals, and view analytics.

## Tech Stack

- **Framework**: Next.js 15 (App Router)
- **UI**: Tailwind CSS v4 + shadcn/ui-style components
- **Charts**: Recharts
- **Auth & Database**: Supabase
- **Language**: TypeScript

## Pages

| Route | Description |
|-------|-------------|
| `/login` | Merchant sign in / sign up / password reset |
| `/dashboard` | Overview with stats, chart, active deals, live redemption feed |
| `/venues` | Venue management — CRUD, photos, hours editor |
| `/deals` | Deal management — create, edit, schedule, toggle, recurrence |
| `/deals/[id]` | Deal analytics — views, redemptions, peak hours, daily breakdown |
| `/analytics` | Aggregate analytics across all venues with date range filter |
| `/settings` | Account profile, notifications, security (password), billing |

## Components

| Component | Purpose |
|-----------|---------|
| `DealForm.tsx` | Multi-step deal creation/edit wizard with recurrence support |
| `RedemptionLog.tsx` | Real-time redemption feed with live polling |
| `AnalyticsChart.tsx` | Recharts line/bar charts with metric toggles and peak hour view |
| `VenueCard.tsx` | Venue profile editor with inline editing and hours management |
| `NavSidebar.tsx` | Fixed left navigation sidebar |
| `StatCard.tsx` | Metric stat card with icon, trend, and color variants |

## Setup

### 1. Clone & Install

```bash
# From the Float repo root
cd merchant-portal
npm install
```

### 2. Configure Supabase

Copy `.env.local` and fill in your Supabase credentials:

```bash
cp .env.local.example .env.local
```

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

### 3. Supabase Schema

Run these migrations in your Supabase SQL editor:

```sql
-- Merchants table
CREATE TABLE merchants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  contact_email TEXT NOT NULL,
  contact_phone TEXT,
  logo_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  notification_preferences JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Venues table
CREATE TABLE venues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  zip TEXT NOT NULL,
  phone TEXT,
  website TEXT,
  cover_image_url TEXT,
  hours JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Merchant-Venues junction
CREATE TABLE merchant_venues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  venue_id UUID REFERENCES venues(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'owner' CHECK (role IN ('owner', 'manager', 'staff')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(merchant_id, venue_id)
);

-- Deals table
CREATE TABLE deals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID REFERENCES merchants(id) ON DELETE CASCADE,
  venue_id UUID REFERENCES venues(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed', 'bogo', 'free_item')),
  discount_value NUMERIC DEFAULT 0,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  recurrence JSONB,
  max_redemptions INTEGER,
  total_redemptions INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Deal analytics
CREATE TABLE deal_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID REFERENCES deals(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  views INTEGER DEFAULT 0,
  redemptions INTEGER DEFAULT 0,
  peak_hour INTEGER,
  revenue_impact NUMERIC,
  UNIQUE(deal_id, date)
);

-- Redemptions
CREATE TABLE redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID REFERENCES deals(id),
  venue_id UUID REFERENCES venues(id),
  merchant_id UUID REFERENCES merchants(id),
  user_id UUID,
  redeemed_at TIMESTAMPTZ DEFAULT NOW(),
  discount_amount NUMERIC NOT NULL,
  status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'pending', 'cancelled'))
);
```

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Deployment

```bash
npm run build
npm start
```

Or deploy to Vercel:

```bash
vercel --prod
```
