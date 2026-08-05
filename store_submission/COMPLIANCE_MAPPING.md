# GraceLog — Store Compliance Mapping

## Apple App Store Guidelines

| Guideline | Requirement | GraceLog Mitigation | Artifact |
|-----------|-------------|---------------------|----------|
| **2.3** — Accurate Metadata | App name, subtitle, and description must accurately reflect functionality. | All ASO metadata reviewed against actual feature set. No exaggerated claims. | `store_submission/ASO_METADATA.md` |
| **2.3.7** — Incentivized Ratings | No manipulation of ratings and reviews. | No in-app prompts for ratings. Organic reviews only. | Code review: no `rate_my_app` dependency |
| **3.1.1** — In-App Purchase | Digital goods must use Apple's IAP system. | Single subscription product `com.gracelog.app.pro.monthly` managed via `in_app_purchase` ^3.1.11. No external payment links. | `lib/core/services/iap_service.dart` |
| **3.1.2** — Subscription Clarity | Auto-renewing subscriptions must clearly state terms, price, and renewal frequency. | Settings screen displays: "$0.99/month, auto-renews until cancelled." Restore button present. | `lib/screens/settings_screen.dart` |
| **3.2** — Other Business Models | No misleading pricing or hidden costs. | Free to use. One visible subscription. No consumables, no loot boxes. | `lib/core/services/iap_service.dart` |
| **4.0** — Design | Apps must provide value and not be a bare-bones template. | 30 features, 57 files, 6 screens, 10 widgets, 500 verses. Branded splash via `flutter_native_splash`. | Full codebase, `pubspec.yaml` splash config |
| **4.1** — Copycats | No copying other apps or intellectual property. | Original UI design using semantic tokens. KJV verses are public domain. | Design audit |
| **5.1.1** — Data Collection & Storage | Apps must request permission for data collection and explain usage. | No data collection. All data local. Privacy policy discloses AdMob identifier usage. | `website/privacy.html`, `ios/Runner/Info.plist` |
| **5.1.2** — Data Use and Sharing | Data must not be shared with third parties without consent. | Journal data never leaves device. AdMob receives only advertising identifier. | `store_submission/DATA_BACKING.md` |
| **5.1.3** — Health & Health Research | Health-related apps must provide accurate data and not give medical advice. | GraceLog is a wellness/journaling app, not a medical device. Disclaimer in description: "Not a substitute for professional mental health care." | `store_submission/ASO_METADATA.md` |
| **5.1.5** — Location Services | Location permission must be justified. | GraceLog does not request location permission. | Code review: no `location` dependency |
| **5.1.8** — Contacts | Contact access must be justified. | GraceLog does not request contact permission. | Code review: no `contacts_service` dependency |
| **5.1.9** — Photos and Videos | Photo library access must be justified. | GraceLog does not request photo library permission. Exports use `share_plus` (system share sheet) or `path_provider` (app sandbox). | Code review: no `photo_manager` dependency |
| **5.2.1** — Intellectual Property | Apps must not infringe third-party IP. | KJV Bible text is public domain. App name "GraceLog" is original. | Trademark search (external) |
| **5.3.4** — Push Notifications | Push notifications must be opt-in and relevant. | Local notifications only (streak reminders). No remote push. User can disable in Settings. `UNUserNotificationCenter` request on first enable. | `lib/platform/notification_service.dart` |
| **5.6.1** — App Tracking Transparency | Apps that track users must implement ATT. | `NSUserTrackingUsageDescription` present in `Info.plist`. AdMob initialization deferred until ATT response (if iOS 14.5+). | `ios/Runner/Info.plist` |

---

## Google Play Store Guidelines

| Guideline | Requirement | GraceLog Mitigation | Artifact |
|-----------|-------------|---------------------|----------|
| **Families Policy** | Apps targeting children must comply with stricter data rules. | GraceLog is rated "Everyone" but not designed for children under 13. No ads targeted to children. | Content rating questionnaire |
| **Payments** | In-app purchases must use Google Play Billing. | Single subscription `com.gracelog.app.pro.monthly` via `in_app_purchase` ^3.1.11 with Google Play backend. | `lib/core/services/iap_service.dart` |
| **Subscriptions** | Must clearly disclose terms and provide cancellation info. | Settings screen shows price, billing frequency, and link to Google Play subscription management. | `lib/screens/settings_screen.dart` |
| **Deceptive Behavior** | No misleading claims or hidden functionality. | All features documented in description. No hidden web views, no cloaked content. | `store_submission/ASO_METADATA.md` |
| **Permissions** | Must request only necessary permissions and explain usage. | `INTERNET` (AdMob, IAP), `POST_NOTIFICATIONS` (streak reminders), `USE_BIOMETRIC` (app lock). All justified in privacy policy and manifest. | `android/app/src/main/AndroidManifest.xml`, `website/privacy.html` |
| **Device and Network Abuse** | Must not abuse device resources or network. | No background services except local notification scheduling. No cryptocurrency mining. No excessive wake locks. | Code review |
| **User Data** | Must handle user data securely and transparently. | All data local. Privacy policy details storage, retention, and deletion. | `website/privacy.html`, `store_submission/DATA_BACKING.md` |
| **Ads** | Must comply with Google AdMob policies and not show disruptive ads. | Banner ads only (no interstitials, no rewarded video). Graceful degradation if AdMob fails. Subscription removes ads. | `lib/platform/admob_service.dart` |
| **Impersonation** | Must not impersonate other brands or entities. | Original branding. No religious institution affiliation claimed. | Brand guidelines |

---

## Regulatory Compliance

| Regulation | Requirement | GraceLog Mitigation | Artifact |
|------------|-------------|---------------------|----------|
| **GDPR (EU)** | Lawful basis for processing, right to erasure, data portability. | No personal data processing. User can export data (JSON/PNG/PDF) and delete by uninstalling. | `website/privacy.html` |
| **CCPA (California)** | Disclosure of data sale, right to opt out. | No data sale. AdMob may process advertising identifiers; users can opt out via device settings or subscription. | `website/privacy.html` |
| **COPPA (US)** | No collection of personal information from children under 13. | No accounts. No data collection. App not directed at children. | Content rating, privacy policy |
| **ePrivacy Directive (EU)** | Consent for cookies / tracking. | No cookies (native app). ATT handles iOS tracking consent. Android ad personalization managed via device settings. | `ios/Runner/Info.plist` |

---

## Pre-Submission Checklist

- [ ] `NSUserTrackingUsageDescription` reviewed by legal counsel.
- [ ] `NSFaceIDUsageDescription` reviewed by legal counsel.
- [ ] Privacy policy URL (`https://gracelog.app/privacy.html`) is live and accessible.
- [ ] Support URL (`https://gracelog.app/support.html`) is live and accessible.
- [ ] App icon meets all size requirements (1024x1024 App Store, 512x512 Play Store, adaptive icons for Android).
- [ ] Screenshots contain no test ads, no debug banners, no placeholder text.
- [ ] IAP product `com.gracelog.app.pro.monthly` is configured in App Store Connect and Google Play Console.
- [ ] AdMob App IDs are replaced with production IDs (not test IDs) before final build.
- [ ] `ExportOptions.plist` contains valid Apple Team ID.
- [ ] `codemagic.yaml` code signing certificates are provisioned.
- [ ] All 11 ARB files are present and `flutter gen-l10n` runs without errors.
- [ ] `flutter analyze --fatal-infos --fatal-warnings` passes cleanly.
- [ ] `flutter test` passes 100%.
