# GraceLog — Data Backing Documentation

## Architecture Overview

GraceLog is a **100% offline, zero-backend** Flutter application. All user data is stored locally on the device using standard platform storage APIs. There is no cloud synchronization, no remote database, and no user account system.

---

## Data Storage Technologies

| Layer | Technology | Platform | Purpose |
|-------|-----------|----------|---------|
| Structured journal entries | SQLite via `sqflite` ^2.3.0 | Cross-platform | CRUD operations, search, streak calculation, mood distribution |
| Unstructured preferences | SharedPreferences via `shared_preferences` ^2.2.2 | Cross-platform | Theme mode, biometric lock, bedtime mode, locale, subscription cache |
| Bundled scripture data | 7 JSON asset files (`assets/scriptures_1.json` – `assets/scriptures_7.json`) | Cross-platform | 500 mood-tagged KJV verses loaded into memory at app start |
| Exported content | Device file system via `path_provider` ^2.1.1 + `share_plus` ^7.2.1 | Cross-platform | JSON, PNG (1080x1080), PDF exports to device gallery or share sheet |

---

## SQLite Schema (Version 1)

**Database name:** `gracelog.db`

**Table:** `entries`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | TEXT | PRIMARY KEY | UUID v4 generated per entry |
| `date` | TEXT | NOT NULL | ISO 8601 date string (`YYYY-MM-DD`) |
| `gratitudeItems` | TEXT | NOT NULL | JSON-encoded `List<String>` of gratitude items |
| `mood` | TEXT | NOT NULL | Enum string: `peaceful`, `thankful`, `joyful`, `hopeful`, `anxious`, `worried`, `tired` |
| `scriptureReference` | TEXT | NULLABLE | Bible reference (e.g., "Philippians 4:6-7") |
| `scriptureText` | TEXT | NULLABLE | Full KJV verse text |
| `category` | TEXT | NULLABLE | User-defined or auto-suggested category |
| `createdAt` | TEXT | NOT NULL | ISO 8601 timestamp |
| `updatedAt` | TEXT | NOT NULL | ISO 8601 timestamp |

**Indices:**
- `idx_entries_date` ON `entries(date)` — accelerates streak queries and date-range lookups
- `idx_entries_mood` ON `entries(mood)` — accelerates mood distribution aggregation

---

## Data Lifecycle

### Creation
- User taps "New Entry" → `DailyEntry` model instantiated with UUID, current date, empty gratitude list, selected `MoodType`.
- On save: model serialized to JSON map → `INSERT OR REPLACE` into SQLite.
- `createdAt` and `updatedAt` set to `DateTime.now().toIso8601String()`.

### Read
- Home Dashboard: `SELECT * FROM entries ORDER BY date DESC LIMIT 1` (today's entry).
- Weekly Review: `SELECT * FROM entries WHERE date >= ? AND date <= ? ORDER BY date DESC`.
- Streak: `SELECT date FROM entries ORDER BY date DESC` → consecutive-day algorithm in Dart.
- Mood Distribution: `SELECT mood, COUNT(*) FROM entries GROUP BY mood`.
- Search: `SELECT * FROM entries WHERE gratitudeItems LIKE ? OR category LIKE ? OR scriptureReference LIKE ? OR scriptureText LIKE ?`.

### Update
- User edits an existing entry → `UPDATE entries SET ... WHERE id = ?`.
- `updatedAt` refreshed to current timestamp.

### Deletion
- Swipe-delete on list tile → `DELETE FROM entries WHERE id = ?`.
- Bulk delete: not exposed in UI (per spec: no batch deletion feature).

### Export
- JSON: `SELECT * FROM entries` → Dart `List<Map>` → `jsonEncode` → `File.writeAsString`.
- PNG: `CustomPainter` renders entry text + scripture at 1080x1080 → `image` package encodes to PNG → `File.writeAsBytes`.
- PDF: Not yet implemented (placeholder in `ExportService` for future phase).

---

## Data Retention & Deletion

Because GraceLog has **no backend**, data retention is entirely under user control:

| Action | Result |
|--------|--------|
| Uninstall app | SQLite database and SharedPreferences are destroyed by the OS |
| Clear app data (Android) | Same as uninstall — all local data erased |
| Offload app (iOS) | App data preserved by iOS; re-download restores data |
| Export before deletion | User can save JSON/PNG/PDF to device gallery or share externally |

There is **no remote data** to delete. A "Delete Account" feature is therefore not applicable and not implemented.

---

## Third-Party Data Access

| Service | Data Accessed | Purpose | Opt-out |
|---------|---------------|---------|---------|
| Google AdMob | Device advertising identifier | Serve banner advertisements | Subscription ($0.99/mo) removes all ads; device settings disable personalized ads |
| Apple App Store / Google Play Store | Transaction receipt (non-identifying) | Verify subscription status | Unsubscribe via platform settings |
| `local_auth` (biometric) | Biometric challenge only | Optional app lock | Disable in Settings |

**No journal content, mood data, scripture selections, or gratitude text is ever transmitted to any third party.**

---

## Backup Behavior

| Platform | Behavior |
|----------|----------|
| iOS (iCloud Backup) | `gracelog.db` in app documents directory is included in iCloud backup by default. User can disable app backup in iOS Settings. |
| Android (Google Backup) | `allowBackup="false"` and `fullBackupContent="false"` in `AndroidManifest.xml` explicitly exclude app data from Google Backup. |

---

## Security Measures

1. **Sandboxing:** All data resides in the OS-provided app sandbox. Other apps cannot access GraceLog's SQLite database or SharedPreferences.
2. **Optional Biometric Lock:** If enabled, the app requires Face ID / Touch ID / fingerprint before displaying journal content. Biometric data is never stored by GraceLog — handled entirely by the device's secure hardware.
3. **No Network Transmission of Journal Data:** The app does not include `http` or `dio` dependencies. The only network calls are AdMob SDK-initiated requests (for ads) and IAP store communication (for subscription verification).
4. **No Encryption at Rest:** The SQLite database is not encrypted. This is a deliberate trade-off for simplicity and performance given the fully offline, single-user nature of the app. If encryption is required in a future update, `sqflite_sqlcipher` would be the migration path.

---

## Compliance Notes

- **GDPR Article 17 (Right to Erasure):** Satisfied by uninstallation or clearing app storage. No remote data exists.
- **GDPR Article 15 (Right of Access):** Satisfied by the in-app JSON export feature.
- **CCPA (California):** GraceLog does not "sell" personal information. AdMob may process advertising identifiers; users can opt out via device settings or subscription.
- **COPPA:** GraceLog is not directed at children under 13. No personal information is collected from any user.
