# Float — App Store Submission Checklist
**Version:** 1.0.0  
**Target:** App Store (iOS)  
**App ID:** com.xomware.float

---

## 📋 Pre-Submission Checklist

### ✅ App Metadata (App Store Connect)

- [ ] **App Name:** "Float" — confirmed unique in App Store
- [ ] **Subtitle:** "Happy Hour Deals Near You" (≤30 chars)
- [ ] **Bundle ID:** `com.xomware.float` — registered in Apple Developer Portal
- [ ] **SKU:** Set in App Store Connect (e.g., `FLOAT-V1`)
- [ ] **Primary Language:** English (U.S.)
- [ ] **Category (Primary):** Food & Drink
- [ ] **Category (Secondary):** Lifestyle *(or Travel — confirm before submit)*
- [ ] **Age Rating:** 17+ (Alcohol References: Frequent/Intense)
- [ ] **Price:** Free (Tier 0)
- [ ] **Availability:** All countries (or restricted list if needed)

---

### ✅ App Description & Keywords

- [ ] `description.txt` — ≤4000 characters, compelling, keyword-rich
- [ ] `subtitle.txt` — ≤30 characters
- [ ] `keywords.txt` — ≤100 characters, comma-separated, no spaces after commas
- [ ] `promotional_text.txt` — ≤170 characters (can be updated without a new submission)
- [ ] `release_notes.txt` — Clear, friendly "What's New" for v1.0.0

---

### ✅ URLs

- [ ] `support_url.txt` — https://float.xomware.com/support (live and accessible)
- [ ] `marketing_url.txt` — https://float.xomware.com (live and accessible)
- [ ] `privacy_url.txt` — https://float.xomware.com/privacy (live and accessible, no auth required)

---

### ✅ Screenshots

Refer to `appstore/screenshots/README.md` for full specs and design guidance.

- [ ] **iPhone 6.7"** — 1290×2796 px — 5 screenshots minimum
  - [ ] Screenshot 1: Discovery Map
  - [ ] Screenshot 2: Deal Detail
  - [ ] Screenshot 3: Deal Feed / Browse
  - [ ] Screenshot 4: Saved Deals / Wishlist
  - [ ] Screenshot 5: Notifications / Following
- [ ] **iPhone 6.1"** — 1179×2556 px — 5 screenshots minimum (can reuse 6.7" if identical)
- [ ] **iPad Pro 12.9"** — 2048×2732 px — Required if app supports iPad
- [ ] All screenshots: PNG or JPEG, sRGB, portrait orientation
- [ ] No placeholder or dummy data visible in screenshots

---

### ✅ App Icon

- [ ] App icon: 1024×1024 px, PNG, no alpha channel, no rounded corners (Apple applies rounding)
- [ ] Icon uploaded to App Store Connect "App Information"
- [ ] Icon also included in Xcode asset catalog at all required sizes

---

### ✅ Build / Binary

- [ ] Archive built with **Release** configuration in Xcode
- [ ] Version number: `1.0.0`
- [ ] Build number: `1` (or increment if re-uploading)
- [ ] Uploaded to App Store Connect via Xcode Organizer or `fastlane deliver`
- [ ] Build processed and available for selection in App Store Connect
- [ ] No bitcode/symbol upload errors
- [ ] `NSLocationWhenInUseUsageDescription` set in `Info.plist`
- [ ] All required permissions have usage descriptions in `Info.plist`
- [ ] App runs without crash on fresh install (simulator + device)

---

### ✅ Privacy

- [ ] App Privacy (Nutrition Label) completed in App Store Connect (see `appstore/privacy.md`)
- [ ] Privacy Policy live at https://float.xomware.com/privacy
- [ ] No tracking → ATT not required; confirm with engineering
- [ ] Third-party SDK privacy disclosures reviewed and added (Firebase, Maps, etc.)

---

### ✅ Legal & Compliance

- [ ] EULA: Using Apple's standard EULA (or custom EULA linked)
- [ ] Copyright notice: "© 2026 Xomware LLC"
- [ ] Export compliance: No encryption beyond standard HTTPS → select "No" for encryption
- [ ] Alcohol content: Age rating set to 17+ (required for alcohol-related apps)
- [ ] No misleading claims in metadata or screenshots
- [ ] Apple Review Guidelines reviewed: https://developer.apple.com/app-store/review/guidelines/

---

### ✅ App Review Information

- [ ] **Demo Account:** Provide if app requires login (username + password in App Review notes)
- [ ] **Review Notes:** Include any special instructions for the reviewer
  - e.g., "This app shows location-based happy hour deals. Location permission is requested on first launch. Please allow location to see nearby deals."
- [ ] **Contact Info:** First name, last name, phone, email for Apple's review team

---

### ✅ Fastlane / Automation

- [ ] `fastlane/Deliverfile` configured with correct `app_identifier` and `username`
- [ ] `APPLE_ID` environment variable set in CI/CD or local `.env`
- [ ] `bundle exec fastlane deliver --validate_only` passes with no errors
- [ ] Screenshots uploaded via `fastlane deliver` or manually

---

### ✅ Final Pre-Submit Checks

- [ ] All URLs are live and load correctly
- [ ] App opens, loads nearby deals, and core flow works end-to-end
- [ ] Push notifications work (if not — document in review notes)
- [ ] App does not crash on iPhone 6.7" and 6.1" (latest iOS)
- [ ] No references to other platforms (Android, etc.) in app or metadata
- [ ] No temporary or beta labels visible in app UI
- [ ] Privacy policy accurately reflects actual data collected

---

## 🚀 Submission Steps

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Select Float → iOS App → version 1.0.0
3. Complete all metadata fields (or run `fastlane deliver`)
4. Upload screenshots
5. Complete App Privacy section
6. Select build from Xcode/TestFlight uploads
7. Fill in App Review Information
8. Click **"Submit for Review"**

---

## 📅 Timeline Expectations

| Step | Estimated Time |
|------|---------------|
| Apple Review (standard) | 24–48 hours |
| Apple Review (complex / rejection) | Up to 7 days |
| Phased rollout (7-day) | Day 1: 1% → Day 7: 100% |

---

## 📞 Contacts

| Role | Contact |
|------|---------|
| Apple Developer Account | ENV["APPLE_ID"] |
| App Review Contact | Set in App Store Connect |
| Support Email | support@float.xomware.com |
| Privacy Contact | privacy@float.xomware.com |
