# Float 🍹

**Real-time deals for bars & restaurants — iOS**

Float surfaces live happy hour specials, limited-time drink/food deals, and venue promos on a map. Users discover deals near them in real-time; venues push offers through a merchant portal.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| iOS App | Swift 5.9 / SwiftUI 5 |
| Backend | Supabase (PostgreSQL + PostGIS) |
| Auth | Sign in with Apple · Google OAuth (Supabase Auth) |
| Maps | MapKit + CoreLocation |
| Realtime | Supabase Realtime |
| Storage | Supabase Storage (venue images) |
| Notifications | APNs via Supabase Edge Functions |

## Project Structure

```
Float/
├── Float/                  # iOS app source
│   ├── App/               # Entry point, app delegate
│   ├── Core/              # Design system, extensions, utilities
│   ├── Features/          # Feature modules (Auth, Map, Deals, Profile)
│   ├── Services/          # Supabase client, auth, location
│   └── Resources/         # Assets, fonts, Info.plist
├── FloatTests/            # Unit tests
├── FloatUITests/          # UI tests
├── supabase/              # Backend: migrations, functions, seed
│   ├── migrations/
│   ├── functions/
│   └── seed/
├── Package.swift          # Swift Package Manager dependencies
└── .github/workflows/     # CI/CD
```

## Getting Started

1. Clone the repo
2. `cp .env.example .env` and fill in Supabase + Firebase credentials
3. Open `Float.xcodeproj` in Xcode 15+
4. Run on iOS 17+ simulator or device

## Sprint 1 — Foundation

- [x] #1 Project scaffolding (SwiftUI architecture, design system)
- [x] #2 Supabase backend (schema, PostGIS, RLS, migrations)
- [x] #3 Auth (Sign in with Apple, Google OAuth, onboarding)

## License

Proprietary — Xomware LLC
