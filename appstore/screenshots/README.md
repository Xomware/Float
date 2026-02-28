# Float — App Store Screenshot Specifications

## Required Sizes

| Device | Resolution | Required |
|--------|-----------|----------|
| iPhone 6.7" (iPhone 15 Pro Max / 14 Plus) | 1290 × 2796 px | ✅ Yes |
| iPhone 6.1" (iPhone 15 / 14) | 1179 × 2556 px | ✅ Yes |
| iPad Pro 12.9" (6th gen) | 2048 × 2732 px | ✅ Yes |

> Note: The 6.7" screenshots can be used as the primary required set for iPhone. iPad screenshots are required if the app supports iPad.

## Screenshot Format
- Format: PNG or JPEG (PNG preferred)
- Color space: sRGB
- No rounded corners, no device frames (unless App Store Connect requests them)
- Portrait orientation unless app is landscape-only

---

## Screenshot Descriptions (5 Required)

### Screenshot 1 — Discovery Map
**Title:** "Find Happy Hour Near You"
**Subtitle:** "Real-time deals on the map"

**UI State:**
- Show the main map view centered on a city (e.g., New York or Chicago)
- Display 8–12 deal pins on the map in Float brand colors
- Bottom sheet partially open showing 2–3 nearby deal cards
- Each card: venue name, deal headline ("$3 Draft Beers"), distance, and star rating
- Status bar: 5:30 PM (happy hour time)
- Top search bar with placeholder "Search bars, restaurants, deals…"

---

### Screenshot 2 — Deal Detail
**Title:** "Every Detail of Every Deal"
**Subtitle:** "Menu, hours, and directions in one place"

**UI State:**
- Open deal detail view for a fictional venue: "The Local Tap Room"
- Show: venue hero image, deal badge ("Happy Hour: 4–7 PM"), deal description
- Deal items listed: "$3 Draft Beer · $5 House Wine · $6 Cocktails · $4 Appetizers"
- Venue info: address, hours (Open until 10 PM), phone, rating (4.2 ⭐)
- CTA buttons: "Get Directions" and "Save Deal"
- Active "Save" heart icon (filled, saved state)

---

### Screenshot 3 — Deal Feed / Browse
**Title:** "Browse Deals Around You"
**Subtitle:** "Filter by drink, food, or vibe"

**UI State:**
- List/feed view of deals (card-based layout)
- Filter chips at top: "All" (selected), "Drinks", "Food", "Wine", "Live Music"
- 4–5 visible deal cards, each with:
  - Venue photo thumbnail
  - Venue name and neighborhood
  - Deal headline (e.g., "Half-Price Appetizers Until 7 PM")
  - Time remaining badge ("Ends in 1h 22m" — shown in red/amber)
  - Distance ("0.3 mi")
- Section header: "Happening Now Near You"

---

### Screenshot 4 — Saved Deals / Wishlist
**Title:** "Save Your Favorite Deals"
**Subtitle:** "Never forget a great happy hour"

**UI State:**
- "Saved" tab / wishlist screen
- 3–4 saved deal cards displayed
- Each card shows venue, deal summary, day/time the deal recurs
- One card highlighted with a "Starting Soon" notification badge
- Empty state partially visible at bottom with CTA "Explore More Deals"
- Subtle section label: "Your Saved Deals (4)"

---

### Screenshot 5 — Notifications / Following
**Title:** "Never Miss Happy Hour Again"
**Subtitle:** "Get alerts when deals go live"

**UI State:**
- Notification/following screen or lock screen mockup showing push notifications
- 2–3 sample push notifications:
  - "🍺 Happy Hour at The Craft House starts in 30 min — $4 IPAs tonight!"
  - "🍷 Half-price wine at Rosso is live NOW — ends at 7 PM"
  - "🎉 New deal added near you: $5 margaritas at Casa Verde"
- Below notifications: the Float app open to "Following" tab
  - Shows 3–4 followed venues with "Following" toggle active
  - Each venue: name, photo, next happy hour time

---

## Design Notes

### Brand Colors (for screenshot overlays/titles)
- Primary: `#FF6B35` (Float Orange)
- Secondary: `#1A1A2E` (Deep Navy)
- Accent: `#F7C948` (Gold/Yellow)
- Background: `#FFFFFF` or `#F9F9F9`

### Text Overlays
- Screenshot title: Bold, 48–60pt, white or navy depending on background
- Subtitle: Regular, 28–34pt, slightly transparent or secondary color
- Place titles at top 25% of screenshot to avoid Apple's UI overlap on device frames

### Tools Suggested
- Figma (preferred) or Sketch for compositing
- Use device frames from [Apple Design Resources](https://developer.apple.com/design/resources/)
- Export at 3x resolution minimum

---

## Localization
For initial v1.0.0 submission, screenshots are required in English (en-US) only.
Additional localizations (es-MX, fr-FR, etc.) can be added in future updates.
