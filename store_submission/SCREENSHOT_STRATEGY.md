# GraceLog — Screenshot Strategy

## Philosophy
Every screenshot must tell a story. We do not show empty states, placeholder text, or generic mock data. All screenshots use realistic, emotionally resonant journal entries with real KJV scripture.

---

## Primary Screenshot Set (iPhone 15 Pro Max — 1290 x 2796)

### Screenshot 1: Home Dashboard — "Your Daily Anchor"
- **Content:** Greeting ("Good morning, friend"), streak flame at 30 days, 7-day mood line chart, scripture card (Psalm 23:1-3, "peaceful" mood), banner ad at bottom.
- **Narrative:** This is the app's heartbeat. The user opens GraceLog and immediately sees their progress, today's verse, and a gentle reminder to journal.
- **Data:** Streak = 30, mood chart shows 5 peaceful, 1 thankful, 1 joyful.
- **Visual:** Light theme, warm gold accent on scripture card, flame animation captured mid-glow.

### Screenshot 2: Daily Entry — "Capture a Moment"
- **Content:** Gratitude input field with 3 items filled ("Morning coffee with my spouse", "A quiet walk before sunset", "The strength to finish a hard project"), mood selector with "thankful" highlighted, auto-suggested category "Relationships", matching scripture (1 Thessalonians 5:18).
- **Narrative:** The core interaction — logging gratitude and receiving scripture. Shows the app's intelligence (category suggestion) and warmth.
- **Visual:** Light theme, keyboard visible, chip-style mood selector, soft sage highlight on "thankful".

### Screenshot 3: Weekly Review — "See Your Growth"
- **Content:** 7-day entry list with dates and mood icons, mood distribution pie chart (4 thankful, 2 peaceful, 1 anxious), category breakdown bar chart, "Export Week" button.
- **Narrative:** Data becomes insight. The user sees patterns in their emotional landscape over time.
- **Visual:** Light theme, clean card layout, chart colors match mood tokens from `AppColors`.

### Screenshot 4: Scripture Detail — "Dwell on the Word"
- **Content:** Full-screen verse display (Isaiah 41:10, "fear not" for "anxious" mood), copy button, share button, "Use this verse" floating action button, reference link to full chapter.
- **Narrative:** Deep engagement with scripture. Not just a snippet — the full verse, actionable.
- **Visual:** Light theme, large serif-like system font at 18pt, generous line height, gold accent on action buttons.

### Screenshot 5: Settings — "Your GraceLog, Your Way"
- **Content:** Theme toggle (Light / Dark / System), Bedtime Mode toggle, Biometric Lock toggle, Language picker showing "English" with dropdown arrow, "Restore Purchases" button, "Export All Data" button, "Privacy Policy" link.
- **Narrative:** Control and transparency. Every setting is explained. No hidden toggles.
- **Visual:** Light theme, clean list tiles with 48dp touch targets, subtle dividers.

### Screenshot 6: Bedtime Mode — "Rest in Gratitude"
- **Content:** OLED-black background, single gratitude input field, dimmed text (#E0E0E0), moon icon, "Save & Sleep" button.
- **Narrative:** The app cares about the user's wellbeing beyond the screen. Reduced eye strain for late-night reflection.
- **Visual:** Pure black (#000000) background, minimal UI, warm dimmed text, no ads.

---

## Secondary Screenshot Set (iPad Pro 12.9" — 2048 x 2732)

### Screenshot 1: Split View — Weekly Review + Entry Detail
- **Content:** Left pane shows weekly entry list; right pane shows selected entry detail with full gratitude items, mood, scripture, and category.
- **Narrative:** iPad's larger canvas enables efficient browsing. The user reviews their week and drills into specific days.
- **Visual:** Light theme, master-detail layout, smooth transitions.

### Screenshot 2: Landscape Mood Chart
- **Content:** Full-width 7-day mood trend line chart with data points, trend line, and mood legend.
- **Narrative:** Data visualization shines on a larger screen. The user sees their emotional arc clearly.
- **Visual:** Light theme, chart fills the width, crisp lines, mood-colored data points.

---

## Android Screenshot Set (Pixel 8 Pro — 1344 x 2992)

Mirrors iOS primary set with platform-specific adjustments:
- Material 3 dynamic color accents (where applicable).
- Android system navigation bar visible.
- Google Play badge not present in screenshots (against store guidelines).

---

## RTL Screenshot Set (Arabic + Hebrew)

### Arabic (ar) — iPhone 15 Pro Max
- **Screenshot 1:** Home Dashboard fully mirrored. Greeting reads "صباح الخير" (Good morning). Streak flame on left. Scripture card text right-aligned. Mood chart legend right-aligned.
- **Visual:** `Directionality` widget correctly applied. Text flows right-to-left. No truncation or clipping.

### Hebrew (he) — iPhone 15 Pro Max
- **Screenshot 1:** Daily Entry screen mirrored. Gratitude input field right-aligned. Mood selector scrolls right-to-left. Scripture reference (תהילים כ״ג:א-ג) displayed correctly with Hebrew numerals.
- **Visual:** Same RTL rigor as Arabic. System Hebrew font renders cleanly.

---

## Dark Mode Screenshot Set

### iPhone 15 Pro Max (Dark)
- **Screenshot 1:** Home Dashboard in dark theme. Background #121212, surface cards #1E1E1E, text #EAEAEA, primary accent #D4A76A. Mood chart uses dark-theme mood colors.
- **Narrative:** The app respects the user's system preference and provides a comfortable low-light experience.
- **Visual:** High contrast maintained (4.5:1 minimum). No pure white elements. Banner ad background blends seamlessly (#1E1E1E).

---

## Localization Screenshot Matrix

| Locale | Screenshots Required | Notes |
|--------|---------------------|-------|
| English (en) | 6 primary + 2 iPad | Master set |
| Spanish (es) | 3 (Home, Entry, Settings) | Key screens with localized strings |
| French (fr) | 3 | Key screens |
| German (de) | 3 | Key screens |
| Portuguese (pt) | 3 | Key screens |
| Arabic (ar) | 2 (Home, Entry) | RTL validation |
| Hebrew (he) | 2 (Home, Entry) | RTL validation |
| Hindi (hi) | 2 (Home, Entry) | Devanagari script validation |
| Japanese (ja) | 2 (Home, Entry) | CJK character density validation |
| Korean (ko) | 2 (Home, Entry) | Hangul layout validation |
| Chinese (zh) | 2 (Home, Entry) | Simplified Chinese, CJK density |

**Total screenshots per release:** ~30 (6 English primary + 2 iPad + 3 x 4 European languages + 2 x 2 RTL + 2 x 4 Asian languages).

---

## Production Checklist

- [ ] All screenshots captured on physical devices (no simulators with debug banners).
- [ ] No `debugShowCheckedModeBanner: true` visible.
- [ ] No test AdMob ads visible in screenshots (use screenshot build with ads disabled).
- [ ] Status bar shows 9:41 AM (Apple convention) or clean Android status bar.
- [ ] Battery at 100%, Wi-Fi connected, no low-power mode indicators.
- [ ] Realistic data: streaks, dates, and scripture references are coherent.
- [ ] Text is legible at thumbnail size (store listing grid view).
- [ ] No personal information, real names, or addresses visible.
- [ ] All 11 languages proofread by native speakers before submission.
