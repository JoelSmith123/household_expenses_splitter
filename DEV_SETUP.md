# Dev Setup Guide

## Quick Start

> **Returning to the project?** This is all you need. Prerequisites must already be installed — see [First-Time Setup](#first-time-setup) if not.

1. Open **Docker Desktop** and wait for it to finish starting (whale icon in menu bar stops animating)

2. **Terminal 1** — start the backend:
    ```bash
    npm run supabase:local
    ```
    This starts the local Supabase stack, then serves edge functions. Keep this terminal open.

3. **Terminal 2** — run the app:
    ```bash
    npm run run:local
    ```

Test login: phone `+16025459712`, OTP `123456`

### Database seeding (optional)

Choose based on what you're working on:

| Working on... | Command |
|---|---|
| Core app features (expenses, categories, splits) | `npm run db:reset:household` |
| Onboarding / auth flow | `npm run db:reset` |

`db:reset:household` resets the schema and loads a two-person household ("The Test House") with categories, ~8 recent expenses, and splits. The test login user (`+16025459712`) is already a member of the household, so you land straight into the app with data.

`db:reset` gives a clean slate — no users, no household — useful for testing the full signup/invite/onboarding path.

---

## First-Time Setup

### Prerequisites

Install these once:

**Flutter SDK** (min 3.5.1)
```bash
brew install --cask flutter
flutter doctor
```

**Xcode** — install from the Mac App Store, then:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

**CocoaPods**
```bash
gem install cocoapods
pod setup
```

**Docker Desktop** — download from https://www.docker.com/products/docker-desktop

**Supabase CLI**
```bash
brew install supabase/tap/supabase
```

**Node.js**
```bash
brew install node
```

---

### Steps

**1. Clone and install Flutter dependencies**
```bash
git clone https://github.com/JoelSmith123/household_expenses_splitter.git
cd household_expenses_sharing_flutter_app
flutter pub get
```

**2. Install iOS pods**
```bash
cd ios && pod install --repo-update && cd ..
```

**3. Create `.env.local`** in the project root (gitignored, never committed):
```bash
# iOS simulator / macOS — use http://10.0.2.2:54321 for Android emulator
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=          # fill in after step 4

ONESIGNAL_APP_ID=           # leave blank for local dev

# Twilio — used by edge functions (placeholders fine for local dev)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_MESSAGE_SERVICE_SID=MGxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_FROM_NUMBER=+10000000000
```

**4. Start the backend and get the anon key**
```bash
npm run supabase:local
```
When `supabase start` finishes it prints an `anon key`. Copy it into `SUPABASE_ANON_KEY` in `.env.local`. The script will then continue into `supabase functions serve` — leave this terminal open.

**5. Run the app**
```bash
npm run run:local
```

---

## How It Works

`npm run supabase:local` does two things in sequence:
1. `supabase start` — pulls and starts a suite of Docker containers for the full Supabase stack
2. `supabase functions serve --no-verify-jwt --env-file .env.local` — serves edge functions via Deno with JWT verification disabled (the Docker-based edge runtime enforces JWT and is disabled in `supabase/config.toml`)

`npm run run:local` sources `.env.local`, boots the iPhone 16e simulator, and runs `flutter run` with the correct `--dart-define` flags.

### Local service URLs

| Service | URL |
|---|---|
| API (PostgREST) | `http://127.0.0.1:54321` |
| Database (PostgreSQL) | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |
| Supabase Studio | `http://127.0.0.1:54323` |
| Inbucket (email testing) | `http://127.0.0.1:54324` |

---

## Reference Commands

```bash
# Status + prints anon key and service role key
supabase status

# Stop all local services
supabase stop

# Reset the database (re-runs migrations + seed.sql)
supabase db reset

# Create a new migration
supabase db diff --use-migra -f <migration_name>

# Open Supabase Studio
open http://127.0.0.1:54323
```

---

## Troubleshooting

**`supabase start` fails immediately**
Docker Desktop isn't running. Open it and wait for it to fully start before retrying.

**`flutter run` can't find simulator device**
The `run:local` script targets `iPhone 16e`. Add that simulator in Xcode → Window → Devices and Simulators, or edit `DEVICE_NAME` in `package.json`.

**Pods errors after Xcode update**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
cd ios && pod install --repo-update
```

**Auth not working / JWT errors**
Run `supabase status` and confirm the `anon key` in the output matches `SUPABASE_ANON_KEY` in `.env.local`.

**First run after a long break**
Use `./ios-flutter-setup.sh` to update Homebrew, Flutter, CocoaPods, and pods, then follow the Quick Start above.
