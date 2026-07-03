# Phase 1 — Foundation: Results

**Status:** ✅ Complete
**Commits:** `09a7640` → `b5be0f2` (+ `dc69187` Android build fix, `4d9a500`/`1ecfad9` auth changes post-phase)

## What was implemented

| Component | File | Notes |
|---|---|---|
| Flutter project | `com.zenvlog.app` | Flutter 3.44.2 / Dart 3.12.2, Android + iOS targets |
| All dependencies | `pubspec.yaml` | Riverpod, Isar, go_router, flutter_map + FMTC, flutter_blue_plus, record, supabase_flutter, sensors_plus, location |
| Design system | `lib/app/theme.dart` | Forest green `#1A3A2A`, cream `#F5F0E8`, amber `#D4A853`; Material 3 |
| Isar singleton | `lib/core/db/isar_service.dart` | Opening deferred to Phase 2 (Isar needs ≥1 schema) |
| Navigation shell | `lib/app/router.dart` | go_router ShellRoute, 4 tabs: Home / Explore / Journal / Profile |
| Auth (added post-phase) | `lib/core/auth/auth_service.dart` | Supabase email auth on first launch (ADR-0007); dev env bypasses it |
| Environments | `lib/core/app_env.dart` | `flutter run` = dev (no keys); `--dart-define=ENV=prod` = real auth |

## Test results

| Test | Result |
|---|---|
| `theme_test.dart` — primary color is forest green | ✅ |
| `theme_test.dart` — card color is cream | ✅ |
| `isar_service_test.dart` — instance asserts before open() | ✅ |
| `nav_shell_test.dart` — unauthenticated → sign-in redirect | ✅ |
| `nav_shell_test.dart` — 4 tabs navigate | ✅ |
| `flutter analyze` | ✅ No issues |
| `flutter build apk --debug` | ✅ Builds |

## Deviations from plan

1. **Isar can't open with zero schemas** — plan's `IsarService.open([])` in main.dart would crash; DB opening moved to Phase 2.
2. **No device attached during build** — "flutter run + tap tabs" verifications replaced by widget tests.
3. **AGP 9 compatibility fixes** (post-phase, on first device run):
   - `isar_flutter_libs` namespace + compileSdk patched in `android/build.gradle.kts`
   - `record` bumped 5.1.2 → 6.1.1 (broken record_linux pairing)
   - `tflite_flutter` dropped until Phase 4 (TF 2.12 AARs have duplicate namespaces AGP 9 rejects)
4. **ADR-0001 reversed by user decision** → ADR-0007: Supabase auth required at first launch; `LocalIdentity` deleted, Supabase user id is the identity. Dev environment added so testing needs no keys.
