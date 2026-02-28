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

## CI/CD — TestFlight Pipeline

### Overview

Float uses **Fastlane** + **GitHub Actions** for automated builds and TestFlight distribution.

```
Push to main  ──►  Lint  ──►  Build + Test  ──►  TestFlight upload
PR to main    ──►  Lint  ──►  Build + Test  (no upload)
```

### GitHub Actions Workflows

| File | Trigger | Purpose |
|------|---------|---------|
| `.github/workflows/ci.yml` | PR/push to `main` | Lint → Build → Test → (TestFlight on merge) |
| `.github/workflows/ios-ci.yml` | PR/push to `main`, `develop` | Legacy SPM build+test |

### Fastlane Lanes

| Lane | Command | When to use |
|------|---------|-------------|
| `beta` | `bundle exec fastlane beta` | Full build + TestFlight upload (CI only) |
| `build_only` | `bundle exec fastlane build_only` | Smoke check — builds archive locally |
| `test` | `bundle exec fastlane test` | Run unit tests |
| `lint` | `bundle exec fastlane lint` | SwiftLint |
| `certs` | `bundle exec fastlane certs` | Sync Match certificates |

### Local Setup

```bash
# Install Bundler and gems
gem install bundler
bundle install

# Sync code signing certs (requires access to cert repo)
bundle exec fastlane certs

# Build locally
bundle exec fastlane build_only

# Run tests
bundle exec fastlane test
```

### GitHub Secrets Required

Configure these under **Settings → Environments → testflight**:

| Secret | Description |
|--------|-------------|
| `APP_STORE_CONNECT_API_KEY_JSON` | ASC API key JSON (key ID, issuer ID, p8 contents) |
| `MATCH_PASSWORD` | Passphrase used to encrypt the Match cert repo |
| `MATCH_GIT_URL` | SSH URL of the private certificate repo |
| `MATCH_SSH_PRIVATE_KEY` | SSH key with read access to cert repo |
| `APPLE_TEAM_ID` | 10-character Apple Developer Team ID |
| `ITC_TEAM_ID` | App Store Connect Team ID |
| `SLACK_WEBHOOK_URL` | (Optional) Slack webhook for release notifications |

### Code Signing — Match

Float uses [fastlane Match](https://docs.fastlane.tools/actions/match/) in **readonly mode** for CI. Certificates and provisioning profiles are stored in a private Git repo (`float-certificates`) encrypted with `MATCH_PASSWORD`.

To rotate certificates:
```bash
# Run locally with write access
MATCH_READONLY=false bundle exec fastlane match appstore --force
```

### Analytics — PostHog

`Float/Services/AnalyticsService.swift` provides a strongly-typed event catalog stub.

**To activate:**
1. Add PostHog via SPM: `https://github.com/PostHog/posthog-ios`
2. Add `POSTHOG_API_KEY` to your `.env` and Xcode build settings → `Info.plist`
3. Uncomment the `import PostHog` and live code blocks in `AnalyticsService.swift` and `FloatApp.swift`

### Crash Reporting — Firebase Crashlytics

`Float/Services/CrashlyticsService.swift` provides a Crashlytics stub.

**To activate:**
1. Add Firebase SDK via SPM: `https://github.com/firebase/firebase-ios-sdk` (FirebaseAnalytics, FirebaseCrashlytics)
2. Download `GoogleService-Info.plist` from Firebase Console → add to `Float/Resources/`
3. Uncomment `import FirebaseCore` / `import FirebaseCrashlytics` blocks
4. Enable **dSYM uploads** in Xcode build phases (Crashlytics Run Script)

### Build Numbers

Build numbers are set automatically in CI using `GITHUB_RUN_NUMBER`, guaranteeing monotonically-increasing values across all TestFlight builds. No manual bumping needed.

---

## License

Proprietary — Xomware LLC
