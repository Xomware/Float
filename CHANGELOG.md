# Changelog

All notable changes to Float are documented here.

## [Unreleased]

## [Sprint 2] — 2026-02
### Added
- Enhanced BookmarksView with improved UX, category filtering, expiring soon warnings (#40)
- Full UserProfile implementation with avatar, display name, stats, and edit functionality (#39)
- Advanced DealFilters panel with venue search, debounce, and trending venues (#38, #37)
- Complete Settings page with account management, appearance, and privacy preferences (#36)
- Social Sharing service with native ShareSheet and deep linking support (#35)
- In-app Analytics Dashboard with Swift Charts, streak tracking, and venue breakdown (#34)
- Notification preferences panel with per-type toggles and quiet hours configuration (#33)

## [Sprint 6] — TestFlight & CI/CD
### Added
- TestFlight CI/CD pipeline with Fastlane and GitHub Actions, build number auto-increment (#21)
- App Store submission metadata, privacy nutrition label, and Deliverfile (#23)
- Float Merchant Portal — Next.js 15 dashboard for managing venues and deals (#24)

## [Sprint 5] — Merchant Portal
### Added
- Float Merchant Portal (web app for venues to post deals and manage analytics) (#24)

## [Sprint 4] — Push Notifications & Polish
### Added
- Full push notification stack with APNs, geofencing, and Supabase edge functions (#22)
- UI polish — skeleton loading, empty states, animations, dark mode refinement (#20)
- Loading skeletons for all list views
- Animated empty states for no deals, no results, no bookmarks
- Full dark mode support with adaptive colors
- Accessibility improvements across all components

## [Sprint 3] — Core Features
### Added
- MapKit deal discovery with color-coded pins and active-now toggle (#18)
- Deal list view with sort (distance, expiry, discount), filter chips, and pagination (#18)
- Deal card and venue profile screens with comprehensive information display (#18)
- Seed data for Nashville (50 venues, 200 active deals) (#19)
- Redemption flow with QR code generation and validation (#19)
- Search functionality with 0.3s debounce, recent searches, and trending venues (#19)
- Bookmarks system with local caching and swipe-to-remove (#19)

## [Sprint 2] — Backend
### Added
- Supabase backend with schema, PostGIS geospatial queries, and RLS policies (#17)
- Automated migrations for venues, deals, user profiles, and redemptions
- `nearby_deals` RPC for efficient location-based deal queries
- Fuzzy search via pg_trgm
- Seed data for 10 NYC venues
- Edge functions for deals, notifications, and analytics

## [Sprint 1] — Foundation
### Added
- Project scaffolding with SwiftUI architecture and MVVM pattern (#16)
- Design system with colors, typography, and reusable components (#16)
- CI/CD setup with GitHub Actions for build and SwiftLint (#16)
- Auth with Sign in with Apple, Google OAuth, and onboarding flow (#15)
- Location service integration (CoreLocation)
- Notification service setup (APNs)
- Logger setup with OSLog

## [v0.1.0-alpha] — Pre-Release Foundation
- Initial project setup and architecture
- Basic SwiftUI scaffolding
- Design system foundations
