# Claude Code Guidelines

## Project Overview

Tally is a Flutter app for sharing household expenses. It uses Supabase for the backend (auth, database, edge functions) and supports ~~iOS, Android, and macOS targets~~ currently just iOS.

For local development setup, see [DEV_SETUP.md](./DEV_SETUP.md).

## Architecture

The architecture must stay scalable and centralized.

Each "page" is structured as its own Widget in a separate `.dart` file, which returns `Consumer<AppState>` if access to state is needed.

Avoid duplication: always check for existing functionality when implementing new functionality. For example, don't create a new login screen if one already exists.

## State

State is managed centrally in a single `lib/providers/app_state.dart` file, containing an `AppState` class which extends `ChangeNotifier`. There are some exceptions to this when needed, such as some of the auth-related signin widgets.

## Style

- Always use **Cupertino** styling. Do not use Material unless there is no Cupertino alternative — and in that case, get permission first.
- Styles (colors, fonts, spacing) are centralized in `lib/styles/app_styles.dart`. Use the existing values; do not hardcode colors or fonts inline.
- **Colors:** primary green `#228B22`, deep green `#196719`, cream `#F9F5D2`, ink `#1B1B1B`, muted `#6B6B6B`
- **Fonts:** Modak for titles; standard system fonts for body/headlines/captions
- **Spacing constants:** xs=8, sm=12, md=16, lg=24, xl=32

## Database

Use the MCP-connected local Supabase instance to inspect the schema and data when figuring out functionality. The main tables are: `users`, `households`, `household_invites`, `expenses`, `user_expenses`, `categories`, `exceptions`.

When writing queries, always account for Row Level Security (RLS) — all tables have RLS policies enabled.

## Environment & Configuration

- Compile-time env vars are passed via `--dart-define` flags (see `npm run run:local` in `package.json`)
- App config is in `lib/config/app_config.dart`
- `enableDebugOverrides` and `debugOverridePage` in app_config can be used to test specific pages during development without going through the full auth flow

## Edge Functions

Edge functions live in `supabase/functions/` and run on Deno v2. Two functions exist:
- `send-household-invite` — sends SMS invites via Twilio
- `send-invite-accepted-push` — sends push notifications via OneSignal

To test edge functions locally: `supabase functions serve`
