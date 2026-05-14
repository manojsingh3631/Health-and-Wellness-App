# BluePond Wellness — Setup & Deployment Guide

**Version:** 1.0.0  
**Last updated:** May 2026  
**Platform:** Android (API 26+) · iOS (15+)  
**Backend:** Supabase (PostgreSQL + Auth + Storage + RLS)  
**Distribution:** Enterprise MDM (Microsoft Intune / Jamf Pro)

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Supabase Project Setup](#2-supabase-project-setup)
3. [Android Build & Sign](#3-android-build--sign)
4. [iOS Build & Archive](#4-ios-build--archive)
5. [MDM Distribution](#5-mdm-distribution)
6. [First-Run Admin Checklist](#6-first-run-admin-checklist)
7. [Ongoing Operations](#7-ongoing-operations)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Prerequisites

### Workstation

| Tool | Version | Notes |
|------|---------|-------|
| Android Studio | Hedgehog 2023.1.1+ | For Android builds |
| JDK | 17 (Temurin) | `JAVA_HOME` must be set |
| Xcode | 15.2+ | macOS only, for iOS builds |
| Supabase CLI | 1.136+ | `npm i -g supabase` |
| Git | Any | Source control |

### Accounts & Access

- **Supabase** — Free or Pro plan at [supabase.com](https://supabase.com)
- **Apple Enterprise Developer Program** — Required for ad-hoc / enterprise IPA distribution (USD 299/yr)
- **Android Signing Keystore** — Generated once, stored securely (see §3.2)
- **MDM Console access** — Microsoft Intune admin or Jamf Pro admin

---

## 2. Supabase Project Setup

### 2.1 Create Project

1. Log in to [supabase.com/dashboard](https://supabase.com/dashboard)
2. Click **New project**
3. Fill in:
   - **Name:** `bluepond-wellness-prod`
   - **Database password:** Generate a strong password and store it in your password manager
   - **Region:** Choose the region closest to your employees (e.g., `us-east-1`)
4. Click **Create new project** and wait ~2 minutes for provisioning

### 2.2 Apply Database Migrations

Navigate to **SQL Editor** in the Supabase dashboard and run each migration in order:

**Step 1 — Initial Schema**

Open `mobile/supabase/migrations/001_initial_schema.sql` and paste the entire contents into SQL Editor. Click **Run**.

Expected output: `Success. No rows returned.`

**Step 2 — Row Level Security Policies**

Open `mobile/supabase/migrations/002_rls_policies.sql` and paste into SQL Editor. Click **Run**.

Expected output: `Success. No rows returned.`

**Step 3 — Seed Data**

Open `mobile/supabase/migrations/003_seed_data.sql` and paste into SQL Editor. Click **Run**.

Expected output: `INSERT 0 12` (app_config) + `INSERT 0 7` (notification_templates) + `INSERT 0 8` (faqs)

### 2.3 Configure Authentication

1. Go to **Authentication → Providers**
2. Ensure **Email** provider is **Enabled**
3. Under Email settings:
   - **Confirm email:** `Disabled` *(employees are pre-provisioned by admin — no self-signup)*
   - **Secure email change:** `Enabled`
4. Go to **Authentication → URL Configuration**
   - **Site URL:** `https://wellness.bluepond.ai` *(or your internal domain)*
   - **Redirect URLs:** Add `ai.bluepond.wellness://auth-callback`

### 2.4 Disable Public Sign-Up

Employees must be pre-created by an admin — public sign-up must be off.

1. Go to **Authentication → Providers → Email**
2. Toggle **Enable sign ups** to **OFF**

> Participants are created by a Super Admin inserting rows into the `participants` table and then calling Supabase Admin API to create the corresponding `auth.users` entry (see §6).

### 2.5 Create Storage Bucket

Medical document uploads require a private storage bucket.

1. Go to **Storage → New bucket**
2. Name: `wellness-medical-docs`
3. Public bucket: **OFF** (private)
4. Click **Create bucket**
5. Go to **Storage → Policies** and add:

```sql
-- Allow participants to upload their own documents
CREATE POLICY "medical_upload_own"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'wellness-medical-docs'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow participants to read their own documents
CREATE POLICY "medical_read_own"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'wellness-medical-docs'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow wellness coordinators and above to read all documents
CREATE POLICY "medical_read_admin"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'wellness-medical-docs'
    AND EXISTS (
        SELECT 1 FROM participants
        WHERE auth_user_id = auth.uid()
        AND role IN ('Wellness Coordinator', 'Org Admin', 'Super Admin')
    )
);
```

### 2.6 Collect API Credentials

Go to **Settings → API** and copy:

| Value | Where used |
|-------|-----------|
| **Project URL** | `SUPABASE_URL` in Android `local.properties` and iOS `Config.plist` |
| **anon public key** | `SUPABASE_ANON_KEY` — used in the app; safe to embed (RLS enforces data isolation) |
| **service_role secret key** | Server-side admin operations **only** — never embed in the mobile app |

---

## 3. Android Build & Sign

### 3.1 Configure Credentials

1. Copy the example credentials file:
   ```bash
   cp mobile/android/local.properties.example mobile/android/local.properties
   ```
2. Open `mobile/android/local.properties` and fill in your values:
   ```properties
   sdk.dir=C\:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
   SUPABASE_URL=https://abcdefghij.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your_actual_key
   ```
3. **Never commit `local.properties` to Git.** Verify `.gitignore` contains `local.properties`.

### 3.2 Generate Signing Keystore (one-time)

```bash
keytool -genkey -v \
  -keystore bluepond-wellness-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias bluepond-wellness \
  -storepass YOUR_STORE_PASS \
  -keypass YOUR_KEY_PASS \
  -dname "CN=BluePond AI, OU=Engineering, O=BluePond AI Inc, L=YourCity, S=YourState, C=US"
```

Store `bluepond-wellness-release.jks` securely (password manager / secrets vault). **Never commit it to Git.**

Add signing config to `mobile/android/app/build.gradle` under `android { }`:

```groovy
signingConfigs {
    release {
        storeFile     file(project.findProperty('KEYSTORE_PATH') ?: 'bluepond-wellness-release.jks')
        storePassword project.findProperty('KEYSTORE_PASS') ?: ''
        keyAlias      project.findProperty('KEY_ALIAS') ?: 'bluepond-wellness'
        keyPassword   project.findProperty('KEY_PASS') ?: ''
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        // ... existing minifyEnabled etc.
    }
}
```

Add to `local.properties`:
```properties
KEYSTORE_PATH=../../bluepond-wellness-release.jks
KEYSTORE_PASS=YOUR_STORE_PASS
KEY_ALIAS=bluepond-wellness
KEY_PASS=YOUR_KEY_PASS
```

### 3.3 Build Release APK

```bash
cd "mobile/android"
./gradlew assembleRelease
```

Output: `app/build/outputs/apk/release/app-release.apk`

### 3.4 Build Release AAB (for Intune managed store)

```bash
./gradlew bundleRelease
```

Output: `app/build/outputs/bundle/release/app-release.aab`

### 3.5 Verify the APK

```bash
# Check signing
apksigner verify --verbose app/build/outputs/apk/release/app-release.apk

# Check min/target SDK, permissions
aapt dump badging app/build/outputs/apk/release/app-release.apk | grep -E "sdkVersion|uses-permission"
```

### 3.6 Debug Build (for testing)

```bash
./gradlew assembleDebug
```

The debug APK uses `applicationId = ai.bluepond.wellness.debug` so it can be installed alongside release on the same device.

---

## 4. iOS Build & Archive

### 4.1 Configure Credentials

1. Copy the template:
   ```bash
   cp "mobile/ios/BluePondWellness/Config.plist" \
      "mobile/ios/BluePondWellness/Config.plist.local"
   ```
2. Open `Config.plist.local` and replace placeholder values:
   ```xml
   <key>SUPABASE_URL</key>
   <string>https://abcdefghij.supabase.co</string>
   <key>SUPABASE_ANON_KEY</key>
   <string>eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your_actual_key</string>
   ```
3. Rename to `Config.plist` (replacing the template):
   ```bash
   mv "mobile/ios/BluePondWellness/Config.plist.local" \
      "mobile/ios/BluePondWellness/Config.plist"
   ```
4. Ensure `Config.plist` is in `.gitignore`.

### 4.2 Open in Xcode

```bash
open "mobile/ios/BluePondWellness.xcodeproj"
```

### 4.3 Configure Signing

1. In Xcode, select the **BluePondWellness** target
2. Go to **Signing & Capabilities**
3. Select your **Apple Enterprise Developer team** from the Team dropdown
4. Ensure **Automatically manage signing** is ON for development
5. For distribution: uncheck automatic, select your **Enterprise Distribution** provisioning profile

### 4.4 Set Bundle Identifier

Set Bundle Identifier to `ai.bluepond.wellness` (must match your provisioning profile).

### 4.5 Archive & Export IPA

**Via Xcode UI:**
1. Select **Any iOS Device (arm64)** as destination
2. **Product → Archive**
3. In the Organizer window, select the archive → **Distribute App**
4. Choose **Enterprise** distribution method
5. Select **Export** → choose export path
6. Result: `BluePondWellness.ipa`

**Via command line (CI/CD):**
```bash
xcodebuild -project "mobile/ios/BluePondWellness.xcodeproj" \
  -scheme "BluePondWellness" \
  -configuration Release \
  -archivePath build/BluePondWellness.xcarchive \
  archive

xcodebuild -exportArchive \
  -archivePath build/BluePondWellness.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/ipa/
```

`ExportOptions.plist` for enterprise distribution:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>enterprise</string>
    <key>teamID</key>
    <string>YOUR_APPLE_TEAM_ID</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
```

---

## 5. MDM Distribution

### 5.1 Microsoft Intune

#### Android APK

1. Sign in to [intune.microsoft.com](https://intune.microsoft.com) → **Apps → All Apps → Add**
2. App type: **Line-of-business app**
3. Upload `app-release.apk`
4. Fill in:
   - **Name:** BluePond Wellness
   - **Publisher:** BluePond AI, Inc.
   - **Minimum operating system:** Android 8.0
5. **Assignments → Add group** → Select the Azure AD security group containing your 200–300 employees
6. Assignment type: **Required** (force-install) or **Available** (self-service from Company Portal)

#### iOS IPA

1. Go to **Apps → iOS/iPadOS → Add**
2. App type: **Line-of-business app**
3. Upload `BluePondWellness.ipa`
4. Fill in app details
5. Assign to the same employee security group
6. Set **Device Enrollment Type** to **Device enrolled** (supervised)

#### App Configuration Policy (inject Supabase URL at MDM level — optional)

1. **Apps → App configuration policies → Add → Managed devices**
2. Platform: **Android Enterprise** (or iOS/iPadOS)
3. Associated app: BluePond Wellness
4. Configuration settings format: **Use configuration designer**
5. Add key `SUPABASE_URL` with value `https://your-project.supabase.co`

### 5.2 Jamf Pro

#### Android APK

1. **Devices → Mobile Device Apps → + New**
2. App type: **In-house application**
3. Upload APK
4. Scope: All managed Android devices (or specific group)

#### iOS IPA

1. **Devices → Mobile Device Apps → + New**
2. App type: **In-house application**
3. Upload IPA
4. Enter your enterprise manifest URL if hosting externally
5. Scope the app to the employee device group

### 5.3 Direct APK Install (Android without MDM)

For smaller deployments or testing without MDM:

1. Enable **Unknown sources** on the device (or use ADB)
2. Transfer APK via email / secure internal link
3. Install via Files app

```bash
# Via ADB (developer mode)
adb install -r app-release.apk
```

---

## 6. First-Run Admin Checklist

Complete these steps **after** Supabase is set up but **before** distributing the app to employees.

### 6.1 Create Super Admin User

In the Supabase **SQL Editor**, run:

```sql
-- Step 1: Create auth user (replace with real email/password)
-- Use Supabase Dashboard → Authentication → Users → Invite user
-- OR use the service_role API:

-- Step 2: After auth user is created, insert participant row
INSERT INTO participants (
    auth_user_id,    -- UUID from auth.users.id
    employee_id,
    full_name,
    email,
    department,
    role,
    shift_type,
    shift_start_hour,
    shift_end_hour,
    status
) VALUES (
    'paste-auth-user-uuid-here',
    'EMP001',
    'Admin Name',
    'admin@bluepond.ai',
    'Engineering',
    'Super Admin',
    'Day',
    9,
    18,
    'Active'
);
```

### 6.2 Create First Challenge

```sql
INSERT INTO challenges (
    challenge_name,
    description,
    start_date,
    end_date,
    status
) VALUES (
    'BluePond Wellness Challenge Q3 2026',
    'A 90-day company-wide wellness challenge tracking steps, hydration, yoga, workouts, and nutrition.',
    '2026-07-01',
    '2026-09-30',
    'Upcoming'
);
```

### 6.3 Add Scoring Configuration

Replace `<challenge-uuid>` with the UUID returned from the challenge insert above.

```sql
INSERT INTO scoring_config (challenge_id, activity_type, points_per_unit, unit_label,
                             threshold_per_unit, daily_max_points, bonus_threshold, bonus_points) VALUES
('<challenge-uuid>', 'Steps',    1,    '1000 steps', 1000,  10,   10000, 2),
('<challenge-uuid>', 'Water',    2,    '250 ml',     250,   8,    2000,  1),
('<challenge-uuid>', 'Yoga',     3,    '15 minutes', 15,    12,   60,    3),
('<challenge-uuid>', 'Workout',  4,    '20 minutes', 20,    16,   60,    4),
('<challenge-uuid>', 'Sugar',    5,    'day',        1,     5,    NULL,  0);
```

### 6.4 Set Active Challenge in App Config

```sql
UPDATE app_config
SET config_value = '<challenge-uuid>'
WHERE config_key = 'active_challenge_id';
```

### 6.5 Bulk Import Participants

Use the Supabase Dashboard → Authentication → **Invite user** for each employee, then insert their participant rows. For bulk imports (200+ employees), use a CSV-driven script:

```bash
# Example using Supabase CLI + service_role key
# Place in scripts/bulk_import.py (not included — write per your HR data format)
# Required columns: employee_id, full_name, email, department, shift_type, shift_start_hour, shift_end_hour
```

> **Tip:** After bulk-creating auth users, run a single SQL INSERT from a CSV using `COPY` in psql or the Supabase Table Editor import feature.

### 6.6 Verify Setup

Run this query to confirm readiness:

```sql
SELECT
    (SELECT COUNT(*) FROM participants)            AS participant_count,
    (SELECT COUNT(*) FROM challenges)              AS challenge_count,
    (SELECT COUNT(*) FROM scoring_config)          AS scoring_rules,
    (SELECT config_value FROM app_config
     WHERE config_key = 'active_challenge_id')     AS active_challenge_id;
```

Expected: participant_count ≥ 1, challenge_count ≥ 1, scoring_rules ≥ 5, active_challenge_id is a valid UUID.

---

## 7. Ongoing Operations

### 7.1 Daily Leaderboard Refresh

The leaderboard is refreshed by a Supabase database function called via a scheduled job. Set this up in **Database → Extensions → pg_cron**:

```sql
-- Enable pg_cron extension (one-time)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule daily leaderboard snapshot at 01:00 UTC
SELECT cron.schedule(
    'daily-leaderboard-refresh',
    '0 1 * * *',
    $$
    INSERT INTO leaderboard_snapshots (challenge_id, participant_id, rank, total_points, snapshot_date)
    SELECT
        al.challenge_id,
        al.participant_id,
        RANK() OVER (PARTITION BY al.challenge_id ORDER BY SUM(al.points_earned) DESC) AS rank,
        SUM(al.points_earned) AS total_points,
        CURRENT_DATE
    FROM activity_logs al
    JOIN challenges c ON c.id = al.challenge_id AND c.status = 'Active'
    WHERE al.is_voided = FALSE
    GROUP BY al.challenge_id, al.participant_id
    ON CONFLICT (challenge_id, participant_id, snapshot_date) DO UPDATE
        SET rank = EXCLUDED.rank,
            total_points = EXCLUDED.total_points,
            refreshed_at = NOW();
    $$
);
```

### 7.2 Streak Calculation

Streaks are calculated in the app (Android: `ScoringEngine.java`, iOS: `ScoringEngine.swift`). Optionally, run a nightly SQL job to update the `current_streak` and `longest_streak` columns in `participants`:

```sql
-- Update streaks (simplified — run nightly via pg_cron)
UPDATE participants p
SET current_streak = (
    SELECT COUNT(DISTINCT log_date)
    FROM activity_logs al
    JOIN challenges c ON c.id = al.challenge_id AND c.status = 'Active'
    WHERE al.participant_id = p.id
    AND al.is_voided = FALSE
    AND al.log_date >= CURRENT_DATE - INTERVAL '30 days'
);
```

### 7.3 App Updates

1. Increment `versionCode` and `versionName` in `app/build.gradle` (Android) and `CFBundleVersion` / `CFBundleShortVersionString` in `Info.plist` (iOS)
2. Build and sign new APK / IPA
3. Upload to Intune / Jamf — enrolled devices receive the update on next check-in (typically within 8 hours)

### 7.4 Monitoring

- **Supabase Dashboard → Logs** — API, auth, and database query logs
- **Supabase Dashboard → Database → Health** — connection pool, query performance
- **Android Crash Reporting** — Integrate Firebase Crashlytics by adding `com.google.firebase:firebase-crashlytics` (optional)
- **iOS Crash Reporting** — Xcode Organizer → Crashes, or Firebase Crashlytics

---

## 8. Troubleshooting

### Android

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Build fails: `SUPABASE_URL not found` | Missing `local.properties` entry | Copy `local.properties.example` → `local.properties` and fill values |
| `401 Unauthorized` from Supabase API | Wrong or expired anon key | Re-copy key from Supabase Dashboard → Settings → API |
| `403 row-level security` error | User not in `participants` table | Insert participant row for this auth user (§6.1) |
| Charts not rendering | MPAndroidChart JitPack not resolved | Ensure `maven { url 'https://jitpack.io' }` is in `settings.gradle` |
| Reminders not firing after reboot | BootReceiver not exported | Verify `android:exported="true"` on `BootReceiver` in `AndroidManifest.xml` |
| Biometric prompt not showing | Device has no enrolled biometrics | Biometric auth is optional — user falls back to PIN/password |

### iOS

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `Config.plist not found` crash | Config.plist missing from bundle | Add `Config.plist` to the Xcode target (Build Phases → Copy Bundle Resources) |
| `401` from Supabase | Missing or wrong `SUPABASE_ANON_KEY` | Re-paste key from Supabase Dashboard into `Config.plist` |
| IPA install fails on device | Provisioning profile mismatch | Re-export IPA with correct Enterprise certificate |
| Push notifications not received | APNS not configured | Register APNS certificate in Supabase → Settings → API → Push Notifications |
| Face ID not prompting | `NSFaceIDUsageDescription` missing | Verify `Info.plist` contains the Face ID key |

### Supabase

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| RLS blocks all reads | `current_participant_id()` returns NULL | Ensure auth JWT is passed in `Authorization` header |
| Migration 002 fails | Migration 001 not run first | Apply migrations in order: 001 → 002 → 003 |
| Storage upload 403 | Bucket policies not applied | Run the 3 `CREATE POLICY` statements from §2.5 |
| Leaderboard empty | No active challenge or no scoring config | Complete §6.2–§6.4 of first-run checklist |

---

## Appendix A — Environment Variables Summary

| Variable | Platform | Where to set |
|----------|----------|--------------|
| `SUPABASE_URL` | Android | `local.properties` |
| `SUPABASE_ANON_KEY` | Android | `local.properties` |
| `SUPABASE_URL` | iOS | `Config.plist` |
| `SUPABASE_ANON_KEY` | iOS | `Config.plist` |
| `KEYSTORE_PATH` | Android CI/CD | `local.properties` or CI secrets |
| `KEYSTORE_PASS` | Android CI/CD | CI secrets only — never commit |
| `KEY_ALIAS` | Android CI/CD | `local.properties` or CI secrets |
| `KEY_PASS` | Android CI/CD | CI secrets only — never commit |

---

## Appendix B — File Structure Overview

```
Health Application/
├── mobile/
│   ├── supabase/migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_seed_data.sql
│   ├── android/
│   │   ├── build.gradle               ← root build config + dependency versions
│   │   ├── settings.gradle            ← JitPack repo + module includes
│   │   ├── gradle.properties          ← JVM args, AndroidX flags
│   │   ├── local.properties.example   ← template — copy to local.properties
│   │   └── app/
│   │       ├── build.gradle           ← app-level dependencies + BuildConfig
│   │       ├── proguard-rules.pro     ← release minification rules
│   │       └── src/main/
│   │           ├── AndroidManifest.xml
│   │           ├── java/ai/bluepond/wellness/
│   │           │   ├── WellnessApp.java
│   │           │   ├── MainActivity.java
│   │           │   ├── SplashActivity.java
│   │           │   ├── auth/           ← Login, Onboarding activities
│   │           │   ├── data/           ← api/, model/, repository/
│   │           │   ├── ui/             ← home/, log/, leaderboard/, progress/, profile/, info/
│   │           │   ├── utils/          ← SessionManager, ShiftAwareUtils, ScoringEngine
│   │           │   └── workers/        ← ReminderSyncWorker, BootReceiver
│   │           └── res/
│   │               ├── layout/         ← all XML layouts
│   │               ├── values/         ← colors, strings, themes
│   │               ├── drawable/       ← vector icons, backgrounds
│   │               ├── navigation/     ← nav_graph.xml
│   │               ├── menu/           ← bottom_nav_menu.xml
│   │               └── xml/            ← network_security_config, backup_rules, file_paths
│   └── ios/BluePondWellness/
│       ├── Info.plist
│       ├── Config.plist               ← Supabase credentials (gitignored)
│       ├── AppDelegate.swift
│       ├── SceneDelegate.swift
│       ├── NotificationDelegate.swift
│       ├── BrandConstants.swift
│       ├── Models/                    ← Codable structs
│       ├── Services/                  ← SupabaseService.swift
│       ├── Utils/                     ← SessionManager, ShiftAwareUtils, ScoringEngine
│       ├── ViewModels/                ← Combine-based ViewModels
│       └── Views/                     ← all UIViewControllers
└── SETUP_AND_DEPLOYMENT.md           ← this file
```

---

*For questions or issues, contact the BluePond Engineering team at engineering@bluepond.ai*
