# Float — App Store Privacy Nutrition Label

> These declarations are required for App Store Connect under "App Privacy."
> Complete this section accurately before submission.
> Apple URL: https://appstoreconnect.apple.com → Your App → App Privacy

---

## Data Collected and Linked to You

These data types are collected and linked to the user's identity:

| Data Type | Category | Purpose | Linked to Identity |
|-----------|----------|---------|-------------------|
| Precise Location | Location | App Functionality (show nearby deals) | No (anonymous) |
| Coarse Location | Location | App Functionality, Analytics | No |
| Name | Contact Info | Account Creation | Yes |
| Email Address | Contact Info | Account Creation, App Functionality | Yes |
| Push Notification Token | Identifiers | App Functionality (deal alerts) | Yes |
| User ID | Identifiers | Analytics, App Functionality | Yes |
| Crash Data | Diagnostics | App Functionality (crash reporting) | No |
| Performance Data | Diagnostics | Analytics | No |
| Other Usage Data | Usage Data | Analytics (in-app behavior) | No |

---

## Data NOT Collected

The following data types are **not** collected by Float:

- ❌ Health & Fitness data
- ❌ Financial information / payment data
- ❌ Browsing history
- ❌ Search history (outside of in-app search)
- ❌ Sensitive info (race, religion, political opinions, etc.)
- ❌ Contacts / address book
- ❌ Photos or videos (unless user uploads a profile photo)
- ❌ Audio / voice data
- ❌ Messages
- ❌ Gameplay content

---

## Data Use Purposes

| Purpose | Data Used |
|---------|----------|
| App Functionality | Location, Email, Push Tokens, User ID |
| Analytics | Coarse Location, Usage Data, User ID, Crash Data |
| Product Personalization | Location, Usage Data |
| Developer's Advertising / Marketing | None |
| Third-Party Advertising | None |

---

## Third-Party SDKs & Their Data Practices

| SDK | Purpose | Data Collected |
|-----|---------|----------------|
| Firebase / Crashlytics | Crash Reporting | Crash logs, device info (not linked to identity) |
| Firebase Analytics | Usage Analytics | Usage events, coarse location (not linked to identity) |
| Mapbox or Apple Maps | Map Display | Location (on-device only, not transmitted) |

> ⚠️ Confirm with your engineering team which analytics/crash SDKs are actually integrated before submission. Each SDK may require its own disclosure.

---

## Tracking

**Does Float track users?** No.

Float does not use data collected from the app to track users across other companies' apps or websites. Float does not participate in behavioral advertising networks.

**App Tracking Transparency (ATT):** Not required (no cross-app tracking). If this changes, add ATT prompt with `NSUserTrackingUsageDescription` in `Info.plist`.

---

## Data Retention

- Location data: Not stored server-side. Used only in real-time to surface nearby deals.
- Account data (email, name): Retained until account deletion.
- Analytics data: Aggregated/anonymized; retained per Firebase/analytics provider policy.

---

## Privacy Policy

Full privacy policy: https://float.xomware.com/privacy

The privacy policy must:
- [ ] Be publicly accessible (no login required)
- [ ] Accurately reflect data practices described above
- [ ] Include contact method for privacy requests
- [ ] Be written in plain language
- [ ] Comply with CCPA (California) and GDPR (EU) if applicable

---

## App Store Connect Selections

When filling out App Store Connect "App Privacy" section, select:

**Location:**
- ☑ Precise Location → App Functionality → Not linked to identity → Not used for tracking

**Contact Info:**
- ☑ Email Address → App Functionality, Account Setup → Linked to identity → Not used for tracking
- ☑ Name → Account Setup → Linked to identity → Not used for tracking

**Identifiers:**
- ☑ User ID → Analytics, App Functionality → Linked to identity → Not used for tracking
- ☑ Device ID → Crash Reporting → Not linked to identity → Not used for tracking

**Usage Data:**
- ☑ Other Usage Data → Analytics → Not linked to identity → Not used for tracking

**Diagnostics:**
- ☑ Crash Data → App Functionality → Not linked to identity → Not used for tracking
- ☑ Performance Data → App Functionality → Not linked to identity → Not used for tracking
