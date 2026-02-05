# household_expenses_sharing_flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Supabase Local Config

This app reads Supabase settings from compile-time environment values.

1. Set values in `.env.local`:

```bash
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=YOUR_LOCAL_ANON_KEY
ONESIGNAL_APP_ID=
```

1. Run with local Supabase:

```bash
npm run run:local
```

Notes:
- For Android emulator, use `http://10.0.2.2:54321` instead of `127.0.0.1`.
- For iOS simulator and macOS, `127.0.0.1` should work as-is.
