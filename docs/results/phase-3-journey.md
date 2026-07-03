# Phase 3 — Journey: Results

**Status:** ✅ Complete
**Commits:** `62c1c44` → (Phase 3 final)

## What was implemented

| Component | File | Notes |
|---|---|---|
| Journey model | `lib/features/journey/journey.dart` | GPS track (parallel lat/lng lists), weather snapshot, distance, isActive/durationHours |
| GpsTracker | `lib/features/journey/gps_tracker.dart` | location stream (5s / 10m filter), haversine distance |
| JourneyNotifier | `lib/features/journey/journey_provider.dart` | start/end lifecycle, cancelable GPS subscription, Open-Meteo weather at start (`'{}'` offline) |
| Journey screen | `lib/features/journey/journey_screen.dart` | Live map with track polyline, stats bar (km/h/points), Start Journey / Get Task FABs |
| TaskTemplate + library | `lib/features/tasks/task_template.dart`, `assets/tasks/library.json` | 20 curated templates: sound/sketch/tactile/reflective across all 6 OSM tags |
| TaskWeaver | `lib/features/tasks/task_provider.dart` | Filters by spot tags, ranks by persona affinity, top 3 |
| Task model + notifier | `lib/features/tasks/task.dart` | Assignment + completion persisted to Isar |
| Task screen | `lib/features/tasks/task_screen.dart` | Accept → timer → capture (audio for sound tasks) → completion writes Task + JournalEntry |
| Audio recorder | `lib/features/audio/audio_recorder.dart` | record 6.x wrapper, m4a to app documents |
| JournalEntry model + notifier | `lib/features/journal/` | Nullable journeyId (entries can exist outside journeys) |
| Journal screen | `lib/features/journal/journal_screen.dart` | Entry list with type icons, FAB text-entry dialog |
| Routing | `lib/app/router.dart` | `/journey/active` and `/task` as full-screen routes; Explore cards → journey |
| Permissions | `AndroidManifest.xml` | RECORD_AUDIO added (location added in Phase 2) |

## Test results

| Test | Result |
|---|---|
| `journey_test.dart` — isActive true while endTime null | ✅ |
| `journey_test.dart` — isActive false after end | ✅ |
| `journey_test.dart` — durationHours calculation | ✅ |
| `task_provider_test.dart` — unmatched required tags excluded | ✅ |
| `task_provider_test.dart` — affinity ranking order | ✅ |
| `task_provider_test.dart` — max 3 suggestions | ✅ |
| Full suite (16 tests) | ✅ All pass (exit 0) |
| `flutter analyze` | ✅ No issues |
| `flutter build apk --debug` | ✅ Builds |

## Golden path (verify on device)

Onboard → Explore → tap arrow on a spot card → Start Journey → GPS polyline draws → Get Task → Accept → Start (records audio for sound tasks) → Complete → entry appears in Journal → End journey.

## Deviations from plan

1. **Task assignment/completion wired in TaskScreen** — the plan said "handled by JourneyScreen" but had no code there. TaskScreen now assigns on accept and, on completion, persists the Task and creates a JournalEntry (audio path or completion text) tagged with the spot.
2. **GPS subscription is cancelable** — the plan's `GpsTracker.stream.listen(...)` leaked; JourneyNotifier holds the subscription and cancels on end/dispose.
3. **`TaskProvider` class renamed `TaskWeaver`** — avoids clashing with Riverpod naming; matches the domain term (Contextual Task Weaver).
4. **Task library is 20 entries, not 80** — covers all 4 types × 6 OSM tags; expanding to 80 is content work, not code.
5. **Journey.taskIds dropped** — Tasks reference `journeyId`; a reverse ID list on Journey was redundant.
6. **Widget test infra** — nav shell test now opens a real Isar (repo-root `libisar.so`) and wraps in ProviderScope; Explore tab excluded from widget tests (needs native FMTC backend), covered on-device.

## Known ceilings (ponytail notes)

- Weather fetch timeout 5s, silent fallback to `'{}'` — Anshin (Phase 4) will surface staleness.
- Journal audio entries show as "AUDIO" rows; playback UI deferred (add when journal detail view exists).
