# CIVILWATCH — Changelog

> All changes made across sessions, ordered newest first.
> Format: **What changed → Why → Files affected**

---

## Session 4 — Modal UX Polish & Error Sanitization
**Date:** September 7, 2026

### 🐛 Bug Fixes

#### Double "Creating your account..." on loading modal
- **What:** The loading dialog was showing the message text twice — once from the shared message block and once from the loading-specific block.
- **Why:** Two separate `if (widget.message != null)` conditions both fired for the loading variant.
- **Fix:** The shared message block now explicitly skips `_DialogVariant.loading`. Only the loading-specific block at the bottom renders it.
- **File:** `prc/civ-main/lib/widgets/common/app_dialog.dart`

#### Raw SQL / database errors shown directly to users
- **What:** When MySQL was down or any server error occurred, the full technical error (e.g. `SQLSTATE[HY000] [2002] No connection could be made...`) was passed straight into the error modal.
- **Why:** `api_client.dart` extracted `json['message']` from Laravel's response without sanitizing it first.
- **Fix:** Added `_sanitizeError(raw, statusCode)` method in `ApiClient._parse()`. It intercepts the raw message before throwing `ApiException` and replaces technical strings with plain-language equivalents.
- **File:** `prc/civ-main/lib/core/network/api_client.dart`

**Error message mapping:**

| Server error | User sees |
|---|---|
| MySQL unreachable / connection refused | "The server is temporarily unavailable. Please try again in a moment." |
| Duplicate email | "That email address is already registered. Please use a different one." |
| Duplicate phone | "That mobile number is already registered. Please sign in instead." |
| Any 500 server error | "Something went wrong on our end. Please try again later." |
| Stack trace / SQL query in message | "An unexpected error occurred. Please try again." |

---

## Session 3 — Modal System & Skeleton Loaders (App + Web)
**Date:** September 7, 2026

### 📱 Flutter Mobile App

#### New: AppDialog widget (loading / success / error)
- **What:** Created a reusable centred modal system replacing all `SnackBar` usage on the register screen.
- **Design goals (age 36–50 users):** Large card (88px icon badge, 20px title, 15px message, 56px full-width button), coloured accent strip at top for instant recognition, smooth scale+fade animation, haptic feedback on success/error.
- **Variants:**
  - `AppDialog.loading(context, message)` — non-dismissible spinner, blocks UI
  - `AppDialog.success(context, title, message, ...)` — green check, user taps Continue
  - `AppDialog.error(context, title, message, ...)` — red icon, "or tap outside to dismiss" hint
  - `AppDialog.hide(context)` — closes the loading dialog
- **File:** `prc/civ-main/lib/widgets/common/app_dialog.dart` *(new file)*

#### New: Skeleton loader widgets
- **What:** Created shimmer skeleton placeholders shown while screens load.
- **Exports:** `SkeletonBox`, `SkeletonBox.circle`, `SkeletonBox.text`, `SkeletonBox.multiline`, `RegisterSkeleton`
- `RegisterSkeleton` mirrors the exact layout of the register form card — shown during the 600ms entrance animation, then swapped for real content.
- **File:** `prc/civ-main/lib/widgets/common/skeleton.dart` *(new file)*

#### Updated: Register screen
- **What:** Replaced all `_showSnack()` / SnackBar error calls with `AppDialog.error()`. Added `_isInitializing` flag that shows `RegisterSkeleton` during entrance animation. Removed dead `_showSnack` method. `PrimaryButton.isLoading` set to `false` (loading is now modal-driven).
- **Flow:** Tap "Create Account" → `AppDialog.loading` → API call → `AppDialog.hide` → `AppDialog.success` (tap Continue → navigate home) or `AppDialog.error` (duplicate phone shows "Sign In" button that pops back to login).
- **File:** `prc/civ-main/lib/screens/auth/register_screen.dart`

### 🌐 Web Admin (Super Admin + Office Admins)

#### New: CwModal JS system
- **What:** `CwModal` object added to `utils.js` with three methods:
  - `CwModal.loading(message)` — non-dismissible full-screen spinner
  - `CwModal.success(title, message, { actionLabel, onAction })` — green check modal
  - `CwModal.error(title, message, { actionLabel, onAction })` — red error modal
  - `CwModal.hide()` — closes current modal
- Single DOM shell (singleton), animated scale+fade entrance, backdrop click closes dismissible modals.
- **File:** `prc/laravel/public/js/utils.js`

#### New: Skeleton loader JS helpers
- **What:** `Skeleton` object added to `utils.js`:
  - `Skeleton.box(w, h, r)` — generic shimmer HTML
  - `Skeleton.text(w)` — single line placeholder
  - `Skeleton.tableRows(rowCount, colCount)` — full tbody skeleton
  - `Skeleton.injectTableRows(tbodyId, rows, cols)` — inject into a table body
  - `Skeleton.clear(tbodyId)` — remove skeleton rows
- **File:** `prc/laravel/public/js/utils.js`

#### New: CSS for CwModal + Skeleton
- **What:** Added full styling for `CwModal` (backdrop, card shell, spinner, icons, button, dark mode) and skeleton shimmer (`sk-box`, `sk-cell`, `sk-row`, `sk-card`, dark mode variants) to the global stylesheet.
- **File:** `prc/laravel/public/css/global.css`

#### Updated: app.js — Api helper + logout + markAllRead
- **What:** Added `Api.action(method, url, body, opts)` — wraps any mutation call with automatic `CwModal.loading → success/error` feedback. Logout now shows loading modal before redirect. `markAllRead` uses silent action.
- **File:** `prc/laravel/public/js/app.js`

#### Updated: auth.js — Login flow
- **What:** Login submission now shows `CwModal.loading("Signing you in...")`, then `CwModal.success` on success (auto-redirects after 1.4s), then `CwModal.error` on wrong credentials or server error. Button no longer shows stale "Logging in..." text.
- **File:** `prc/laravel/public/js/auth.js`

#### Updated: users.js — CRUD operations
- **What:** `loadUsers()` now injects skeleton rows while fetching. Save user and delete user replaced with `Api.action()` calls — shows loading → success → error modals automatically. Removed old inline `showAlert` / `apiFetch` save/delete blocks.
- **File:** `prc/laravel/public/js/users.js`

---

## Session 2 — Remove Dummy Reports, Fix Raw SQL Leak on Registration
**Date:** September 7, 2026

### 🗄️ Database — Remove Dummy Seeded Reports

#### Stubbed: CitizenReportSeeder
- **What:** `CitizenReportSeeder.php` replaced with a no-op stub that prints "skipped" instead of inserting 10 dummy reports + 3 fake citizens.
- **Why:** Dummy data (Juan Dela Cruz, Maria Santos, Pedro Reyes + 10 reports CW-2026-00101 to 00110) was appearing in the super admin panel alongside real submissions.
- **File:** `prc/laravel/database/seeders/CitizenReportSeeder.php`

#### Updated: DatabaseSeeder
- **What:** Removed `$this->call(CitizenReportSeeder::class)` — dummy reports will never re-seed after `php artisan db:seed`.
- **File:** `prc/laravel/database/seeders/DatabaseSeeder.php`

#### New: ClearDummyReports artisan command
- **What:** `php artisan reports:clear-dummy` (dry-run preview) and `php artisan reports:clear-dummy --force` (actually deletes) to wipe existing dummy data from the live MySQL database.
- **Deletes in safe order:** `citizen_notifications` → `report_activities` → `citizen_reports` → fake citizen accounts (only if they have no real reports attached).
- **File:** `prc/laravel/app/Console/Commands/ClearDummyReports.php` *(new file)*

**Run once on your server:**
```bash
php artisan reports:clear-dummy          # preview
php artisan reports:clear-dummy --force  # delete
```

### 🔒 Laravel — Fix Raw SQL Error on Duplicate Phone Registration

#### Updated: MobileAuthController — register method
- **What:** Added `use Illuminate\Database\QueryException` and `use Illuminate\Validation\ValidationException`. The `register()` method now:
  1. Validates phone uniqueness with a custom closure before hitting the DB (returns clean 422 with friendly message)
  2. Catches `QueryException` with error code 1062 as a race-condition safety net
  3. Returns plain-language JSON — never exposes raw SQL or stack traces
- **Before:** `SQLSTATE[23000]: Integrity constraint violation: 1062 Duplicate entry '639638527411'...` shown in app
- **After:** `"This mobile number is already registered. Please sign in instead."`
- **File:** `prc/laravel/app/Http/Controllers/Mobile/MobileAuthController.php`

---

## Session 1 — Server Hop Script UI Redesign
**Date:** September 7, 2026

### 🎮 Roblox Script — serverhopscript.lua

#### Redesigned: Full UI overhaul
- **What:** Replaced the old compact chat-bubble panel UI with a futuristic dark-navy design matching the "Steal An Egg" screenshot reference.
- **All logic functions unchanged:** `scanCurrentServerEggs`, `fetchAllServers`, `tpTo`, `refreshServerList`, `hopRandom`, `hopLowest`, `rejoin`, `joinOnce`, all button wiring, and the live monitor loop are identical to the original.

**New UI structure:**

| Section | Content |
|---|---|
| Header bar | Egg icon badge, "STEAL AN EGG" title, "BETTER EGGS / BIGGER WINS" tags, minimize + close buttons |
| Section 1 — Server Detail | Server ID (truncated), live player count, ping/fps |
| Section 2 — Egg Information | 3 stat tiles (top 3 rarity tiers, live-updated), best egg label, egg list breakdown |
| Section 3 — Go To Server | Player threshold input, full-width gradient "⚡ HOP NOW" button |
| Section 4 — Auto Toggle | ON/OFF pill button with live status label ("Watching…", "Hopping…", "Idle"), Lowest + Rejoin half-buttons |
| Section 5 — Server List | Column-header row, status text, Refresh button |
| Section 6 — Status | Current operation feedback label |

**Style changes:**
- Colour palette: deep navy (`#08_0A1C`), purple/cyan accents, `UIGradient` on bubble orb + hop button
- Panel size: 310×520 (was 250×370)
- `UIStroke` borders on every card, `UIGradient` on bubble orb
- Bubble icon changed from 💬 to 🥚
- Auto toggle button styled as pill (OFF/ON state with colour change)

- **File:** `APP-WITH-WEB/serverhopscript.lua`

---

## How to use `Api.action` on any web admin page

```js
// Example: validate a report
await Api.action('POST', '/api/admin/citizen-reports/5/validate', {}, {
  loading:      'Validating report...',
  success:      'Report validated and published to the community map.',
  successTitle: 'Report Validated',
  errorTitle:   'Validation Failed',
  onSuccess:    () => loadReports(),  // refresh table after user dismisses modal
});

// Example: delete something silently (no modal)
await Api.action('DELETE', '/api/admin/offices/3', {}, { silent: true });
```

## How to use `AppDialog` anywhere in Flutter

```dart
// Loading (non-dismissible)
AppDialog.loading(context, message: 'Submitting your report...');

// Hide loading
AppDialog.hide(context);

// Success
await AppDialog.success(
  context,
  title: 'Report Submitted!',
  message: 'Your concern has been received. We will review it shortly.',
  actionLabel: 'View My Reports',
  onAction: () => Navigator.pushNamed(context, AppRoutes.myReports),
);

// Error
await AppDialog.error(
  context,
  title: 'Could Not Submit',
  message: 'Please check your internet connection and try again.',
  actionLabel: 'Try Again',
);
```

## How to use `Skeleton` on any web admin table

```js
// Inject skeletons while loading
Skeleton.injectTableRows('reportsTableBody', 8, 6);

// Replace with real rows when data arrives
tbody.innerHTML = realRowsHtml;
```

---

## Session 5 — Severity Removal, Real Photo Picker, Admin Live Data, IP Fix
**Date:** September 7, 2026

---

### ✂️ Severity Removed from Mobile App

**Why:** Severity (Low / Medium / High) is a judgment call best made by the admin when assigning a report to a government office — not by the citizen. Showing it in the app added confusion without value.

**What was removed:**
- The entire Severity section UI (label, chips, helper text) from `report_details.dart`
- The `_severity` state variable from `report_details.dart`
- The dead `_SeverityChip` widget class from `report_details.dart`
- The Severity section UI from `report_location.dart`
- The `_severity` state variable from `report_location.dart`
- The dead `_SeverityChip` widget class from `report_location.dart`
- The Severity row from the review card in `report_review.dart`
- The `severity`, `severityColor`, `severityBg` variables from `report_review.dart` build method

**What stays:**
- `severity: 'Moderate'` is passed silently in `_next()` on both `report_details.dart` and `report_location.dart` so the database column constraint is satisfied without breaking the API
- The `severity` column remains in the `citizen_reports` table
- The admin assign-office page keeps full severity/priority control

**Files changed:**
- `prc/civ-main/lib/screens/report/report_details.dart`
- `prc/civ-main/lib/screens/report/report_location.dart`
- `prc/civ-main/lib/screens/report/report_review.dart`

---

### 📷 Real Photo Picker + Fullscreen Modal

**Why:** The old photo step was fake — `_simulatePhoto()` just flipped a boolean. No real image was ever picked, previewed, or uploaded. The photo preview showed a dark rectangle with the issue name as text.

**What changed in `report_photo.dart` (full rewrite):**

| Before | After |
|---|---|
| `_simulatePhoto()` flips a boolean | `ImagePicker.pickImage()` opens real camera or gallery |
| Dark rectangle placeholder with issue name text | `Image.file()` shows the actual picked photo |
| No fullscreen view | Tap preview → `InteractiveViewer` fullscreen modal (pinch to zoom, tap anywhere to close) |
| "Take Photo" / "Gallery" buttons always visible | Picker buttons shown only when no photo selected; after picking, shows preview + "Change Photo" button that opens a bottom sheet |
| No "Skip" label when no photo | Footer button says "Skip →" when no photo, "Next →" when photo is picked |
| Button: `onPressed: _simulatePhoto` | Button: `onPressed: () => _pickImage(ImageSource.camera/gallery)` |

**Fullscreen modal details:**
- `showDialog` with `barrierColor: Colors.black.withOpacity(0.92)`
- `InteractiveViewer` with `minScale: 0.8`, `maxScale: 4.0`
- Close button (top-right) + "Pinch to zoom • Tap anywhere to close" hint at bottom
- `GestureDetector` wrapping the whole scaffold closes on tap

**What changed in `report_review.dart`:**
- Photo row now shows a real `Image.file` thumbnail (80×60px, rounded corners) when `photoFile` is present
- Tapping the thumbnail opens the same fullscreen `InteractiveViewer` modal
- `XFile? photoFile` extracted from `widget.reportData['photoFile']`
- `dart:io` and `image_picker` imports added

**What changed in `report_service.dart`:**
- `submitReport()` now reads `data['photoFile']` as `XFile`
- Builds a real `http.MultipartFile.fromPath('photo', ...)` and attaches it to the multipart POST
- `import 'package:http/http.dart' as http` and `import 'package:image_picker/image_picker.dart'` added
- `street` field added from `data['address']` for the API

**What changed in `pubspec.yaml`:**
- Added `image_picker: ^1.1.2` to dependencies
- Ran `flutter pub get` — resolved successfully

**Files changed:**
- `prc/civ-main/lib/screens/report/report_photo.dart` *(full rewrite)*
- `prc/civ-main/lib/screens/report/report_review.dart`
- `prc/civ-main/lib/services/report_service.dart`
- `prc/civ-main/pubspec.yaml`

---

### 🌐 Pending Reports Page Wired to Real Database

**Why:** `pending-reports.html` had 6 hardcoded dummy rows in a JavaScript array. It never called the API. The super admin could submit a real report from the phone and refresh the page — nothing would appear.

**What changed:**
- Removed the entire `pendingReports = [...]` array and all hardcoded row data
- Replaced with `loadPendingReports()` that calls `GET /api/admin/citizen-reports` for both `status=Submitted` and `status=Pending Validation` in parallel using `Promise.all`
- Results are merged, deduplicated by `id`, and sorted newest first
- Skeleton rows (`Skeleton.injectTableRows`) shown while loading
- Pagination is now real — `goPage(n)` slices `filtered` array, `renderPagination()` generates clickable page buttons with disabled states
- Search and category/barangay filters work against live data
- **Auto-refresh every 30 seconds** — new reports appear without manually reloading the page
- Empty state: shows inbox icon + "No pending reports found."
- Error state: shows wifi_off icon + "Could not load reports. Check your connection."
- The stat card counter updates with the real count from the API response

**Data mapping from API → table columns:**

| Column | API field |
|---|---|
| Reference ID | `r.referenceNumber` or `r.reference_number` |
| Photo | `r.imageUrl` or `r.photo_url` — falls back to placeholder icon |
| Issue | `r.issue` or `r.concern` |
| Category | `r.category` → `Utils.categoryBadge()` |
| Barangay | `r.barangay` |
| Submitted By | `r.citizen.fullName` + `r.citizen.phoneNumber` |
| Date/Time | `r.submittedAt` formatted with `toLocaleDateString` |
| Actions | View link → `report-details.html?id={r.id}` |

**File changed:**
- `prc/laravel/public/pending-reports.html`

---

### 📡 Flutter API Base URL Fixed for Real Device

**Why:** `baseUrl` was `http://127.0.0.1:8000/api`. On a real Android phone, `127.0.0.1` resolves to the phone itself — not the laptop running Laravel. Every API call from the phone silently failed (connection refused), so submitted reports never reached the database.

**What changed:**

| | Before | After |
|---|---|---|
| `baseUrl` | `http://127.0.0.1:8000/api` | `http://10.0.7.127:8000/api` |
| `APP_URL` in `.env` | `http://localhost` | `http://10.0.7.127:8000` |
| Laravel config cache | stale | cleared via `php artisan config:clear` |

**CORS:** Already set to `allowed_origins: ['*']` in `config/cors.php` — no change needed.

**Important:** Laravel must be started with `--host=0.0.0.0` to listen on all interfaces:
```bash
cd prc/laravel
php artisan serve --host=0.0.0.0 --port=8000
```

**If your IP changes** (different WiFi network), update `baseUrl` in:
`prc/civ-main/lib/core/constants/api_constants.dart`

Run `ipconfig` on Windows → look for **IPv4 Address** under your active WiFi adapter.

**Files changed:**
- `prc/civ-main/lib/core/constants/api_constants.dart`
- `prc/laravel/.env`

---

### 📋 Full File Change List — Session 5

| File | Change |
|---|---|
| `prc/civ-main/lib/screens/report/report_details.dart` | Removed severity section, state, widget class |
| `prc/civ-main/lib/screens/report/report_location.dart` | Removed severity section, state, widget class |
| `prc/civ-main/lib/screens/report/report_photo.dart` | Full rewrite — real image_picker, preview, fullscreen modal |
| `prc/civ-main/lib/screens/report/report_review.dart` | Real API submission, real photo thumbnail, severity row removed |
| `prc/civ-main/lib/services/report_service.dart` | Attaches XFile as multipart, street field added, imports added |
| `prc/civ-main/pubspec.yaml` | Added `image_picker: ^1.1.2` |
| `prc/laravel/public/pending-reports.html` | Real API, skeleton, pagination, auto-refresh, no dummy data |
| `prc/civ-main/lib/core/constants/api_constants.dart` | baseUrl → `10.0.7.127:8000` |
| `prc/laravel/.env` | APP_URL → `http://10.0.7.127:8000` |
