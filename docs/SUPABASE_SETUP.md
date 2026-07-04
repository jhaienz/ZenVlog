# Supabase Setup (prod builds)

Dev builds (`flutter run`, default) need none of this — auth is bypassed and the feed is fake. Do this once before building with `--dart-define=ENV=prod`.

## 1. Create the project

1. [supabase.com](https://supabase.com) → New project (free tier is fine).
2. Note the **Project URL** and the **anon/publishable key** (Project Settings → API).

## 2. Run the migration

SQL Editor → paste the contents of `supabase/migrations/0001_initial.sql` → Run.
Creates `posts` + `follows` with RLS and PostGIS. (Or `supabase db push` with the CLI.)

## 3. Storage bucket

Storage → New bucket:
- Name: `post-media`
- Public: **yes**
- File size limit: 10MB
- Allowed MIME types: `image/jpeg,image/png,audio/m4a`

## 4. Auth

Authentication → Providers → Email: enabled (default). No magic link needed — the app uses email + password.

## 5. Fill env.dart

Copy `lib/core/env.example.dart` to `lib/core/env.dart` (gitignored) and fill:

```dart
const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const supabaseAnonKey = 'YOUR_PUBLISHABLE_KEY';
```

## 6. Build

```bash
flutter build apk --release --dart-define=ENV=prod
```
