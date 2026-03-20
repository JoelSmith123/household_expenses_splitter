# Dev Setup Guide

This project uses the **Supabase CLI** to run a full Supabase stack locally. The CLI manages a suite of Docker containers under the hood — you don't write or edit any Dockerfiles yourself; Docker Desktop just needs to be running.

## How the Local Server Works

Running `supabase start` launches the following Docker-managed services:

| Service | URL | Purpose |
|---|---|---|
| Supabase API (PostgREST) | `http://127.0.0.1:54321` | The main API endpoint the Flutter app connects to |
| PostgreSQL database | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` | Direct DB access (e.g. for migrations, psql) |
| Supabase Studio | `http://127.0.0.1:54323` | Browser dashboard — inspect tables, run queries, manage auth |
| Inbucket (email testing) | `http://127.0.0.1:54324` | Catches all outbound emails locally; view them in browser |
| Analytics | `http://127.0.0.1:54327` | Local analytics backend |
| Edge Function Inspector | `http://127.0.0.1:8083` | Chrome DevTools inspector for debugging edge functions |

The database schema is applied automatically from `supabase/migrations/` when you run `supabase start` or `supabase db reset`.

---

## Prerequisites

Install the following before starting:

### 1. Flutter SDK

```bash
# Install via Homebrew
brew install --cask flutter

# Verify
flutter doctor
```

Minimum version: `3.5.1`. Run `flutter upgrade` if yours is older.

### 2. Xcode (iOS/macOS development)

Install from the Mac App Store, then:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 3. CocoaPods (iOS native dependencies)

```bash
gem install cocoapods
pod setup
```

### 4. Docker Desktop

The Supabase CLI requires Docker Desktop to be **running** before you start the local server.

Download and install from: https://www.docker.com/products/docker-desktop

After install, open Docker Desktop and wait for it to finish starting up (the whale icon in your menu bar should be steady, not animating).

### 5. Supabase CLI

```bash
brew install supabase/tap/supabase
```

Verify:

```bash
supabase --version
```

### 6. Node.js + npm

Required for the `npm run run:local` convenience script.

```bash
brew install node
```

---

## Step-by-Step Setup

### Step 1 — Clone and install Flutter dependencies

```bash
git clone https://github.com/JoelSmith123/household_expenses_splitter.git
cd household_expenses_sharing_flutter_app

flutter pub get
```

### Step 2 — Install iOS pods

```bash
cd ios && pod install --repo-update && cd ..
```

### Step 3 — Create your `.env.local` file

Copy the template below and save it as `.env.local` in the project root. This file is gitignored and never committed.

```bash
# .env.local

# Local Supabase API URL
# iOS simulator / macOS:
SUPABASE_URL=http://127.0.0.1:54321
# Android emulator — uncomment and use this instead:
# SUPABASE_URL=http://10.0.2.2:54321

# Filled in after running `supabase start` (see Step 5)
SUPABASE_ANON_KEY=

# Optional: OneSignal push notifications (leave blank for local dev)
ONESIGNAL_APP_ID=

# Twilio credentials for SMS (used by edge functions)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_MESSAGE_SERVICE_SID=MGxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Step 4 — Start Docker Desktop

Open the Docker Desktop app and wait until it's fully running before proceeding.

### Step 5 — Start the local Supabase stack

```bash
supabase start
```

This pulls and starts all the Docker containers (first run takes a few minutes to download images). On success you'll see output like:

```
Started supabase local development setup.

         API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
  S3 Storage URL: http://127.0.0.1:54321/storage/v1/s3
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Copy the `anon key` value and paste it as `SUPABASE_ANON_KEY` in your `.env.local`.

### Step 6 — Run the app

```bash
npm run run:local
```

This script:
1. Sources your `.env.local` variables
2. Finds and boots the iPhone 16e simulator
3. Runs `flutter run` with the correct `--dart-define` flags for local Supabase

---

## SMS / Auth Testing

The local Supabase config has pre-set test OTP codes for phone auth — no real SMS is sent:

| Phone number | OTP code |
|---|---|
| `+16025459712` | `123456` |
| `6025459712` | `123456` |

Use these numbers in the app's phone auth flow during local development.

---

## Useful Commands

```bash
# Check status of running local services
supabase status

# Stop all local services
supabase stop

# Reset the database (re-runs all migrations + seed.sql)
supabase db reset

# Serve edge functions locally with hot reload
supabase functions serve

# Create a new migration
supabase db diff --use-migra -f <migration_name>

# Open Supabase Studio in browser
open http://127.0.0.1:54323
```

---

## Full Reset / First-Time Dependency Update

If you're setting up from scratch after a long break or a major Xcode/Flutter update, use the `ios-flutter-setup.sh` script. It updates Homebrew, Flutter, CocoaPods, and pods, then opens the simulator.

```bash
./ios-flutter-setup.sh
```

After it completes, follow from Step 5 above.

---

## Troubleshooting

**`supabase start` fails immediately**
Make sure Docker Desktop is open and fully running before running `supabase start`.

**`flutter run` can't find simulator device**
The `run:local` script targets `iPhone 16e`. If you don't have that simulator, open Xcode → Window → Devices and Simulators and add it, or edit the `DEVICE_NAME` in `package.json`.

**Pods errors after Xcode update**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
cd ios && pod install --repo-update
```

**Auth not working / wrong anon key**
Run `supabase status` to see the current anon key and make sure it matches what's in `.env.local`.
