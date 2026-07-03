# ZenVlog Development Roadmap

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build ZenVlog in 6 sequential phases, each producing a testable vertical slice. Phases 1–3 deliver a fully functional solo app; phases 4–6 layer in intelligence, group, and community.

**Architecture:** Feature-first Flutter monorepo. Riverpod 2.x for state, Isar for local storage, go_router for navigation. All personal data stays on-device; Supabase only initializes in Phase 6.

**Tech Stack:** Flutter (Dart), Riverpod 2.x + code gen, go_router, Isar, flutter_map + flutter_map_tile_caching, flutter_blue_plus, record, tflite_flutter, supabase_flutter, freezed + json_serializable

## Global Constraints

- Minimum Flutter SDK: 3.22.0
- Minimum Dart SDK: 3.4.0
- Target: iOS 16+ and Android API 26+
- Package name: `com.zenvlog.app`
- Supabase Auth on first launch (ADR-0007); the Supabase user id is the user's identity everywhere — replace any `LocalIdentity` references in phase plans
- No personal data (persona, journeys, journal) sent to any server in any phase; only feed posts (Phase 6) touch Supabase tables
- All Isar models annotated with `@collection`
- All Riverpod providers use code generation (`@riverpod` annotation)
- go_router routes defined as `GoRoute` constants, not inline strings
- Dark forest green primary: `Color(0xFF1A3A2A)`, cream cards: `Color(0xFFF5F0E8)`, amber accent: `Color(0xFFD4A853)`

---

## Project File Structure

```
lib/
  main.dart                         # app entry, Isar init, ProviderScope
  app/
    router.dart                     # all GoRoute definitions
    theme.dart                      # ThemeData (green/cream/amber)
  features/
    onboarding/
      onboarding_screen.dart        # sliders → Persona, UUID generation
    persona/
      persona.dart                  # Isar model + freezed DTO
      persona_provider.dart         # Riverpod: read/write persona
    explore/
      spot.dart                     # Isar model for Hidden Spot
      serendipity_scraper.dart      # OSM filter + persona ranking
      explore_screen.dart           # map + spot list
    journey/
      journey.dart                  # Isar model (GPS track, stats, weather)
      journey_provider.dart         # active journey state
      journey_screen.dart           # live navigation view
      gps_tracker.dart              # location stream → track points
    tasks/
      task_template.dart            # curated library entry (bundled JSON)
      task.dart                     # Isar model (assigned task instance)
      task_provider.dart            # filter library → assign task
      task_screen.dart              # accept / complete task UI
    journal/
      journal_entry.dart            # Isar model (text/audio/photo/sketch)
      journal_provider.dart
      journal_screen.dart
    audio/
      audio_recorder.dart           # wraps `record` package
    anshin/
      anshin_engine.dart            # forecast + hazard + barometer
      forecast_cache.dart           # download + read cached forecast JSON
      hazard_overlay.dart           # OSM hazard geometry loader
    group/
      group.dart                    # in-memory model (not persisted)
      ble_scanner.dart              # flutter_blue_plus scan/advertise
      group_provider.dart           # gossip state machine
      group_screen.dart             # discovery + member list UI
    community/
      community_account.dart        # Supabase auth wrapper
      post.dart                     # Supabase row model
      feed_provider.dart
      feed_screen.dart
    profile/
      profile_screen.dart           # persona radar, stats, badges
      badges_screen.dart
  core/
    db/
      isar_service.dart             # singleton Isar instance
    identity/
      local_identity.dart           # UUID in flutter_secure_storage
    maps/
      tile_cache_manager.dart       # flutter_map_tile_caching config
      osm_downloader.dart           # OSM PBF download + parse
assets/
  tasks/
    library.json                    # curated task templates (~80 entries)
  hazards/
    hazard_zones.geojson            # static flood/ridgeline overlays
```

---

## Phase 1 — Foundation

**Deliverable:** Blank app that navigates between 4 tabs, uses the design system, persists nothing yet. The shell every feature plugs into.

**Detailed plan:** Write when ready to start. Key tasks:

- [ ] `flutter create com.zenvlog.app` with correct org and package name
- [ ] Add all dependencies to `pubspec.yaml` (Riverpod, Isar, go_router, flutter_map, flutter_blue_plus, record, tflite_flutter, supabase_flutter, freezed, json_serializable, flutter_secure_storage, build_runner)
- [ ] `theme.dart` — `ThemeData` with green/cream/amber palette, custom text styles
- [ ] `isar_service.dart` — singleton open/close, schema registration stub
- [ ] `local_identity.dart` — generate UUID on first launch, persist in `flutter_secure_storage`
- [ ] `router.dart` — 4-tab shell: Home, Explore, Journal, Profile; placeholder screens
- [ ] `main.dart` — `ProviderScope` wrapping `MaterialApp.router`, Isar init on startup
- [ ] Golden-path smoke test: app launches, tabs navigate, UUID persists across restarts

**Depends on:** nothing
**Unlocks:** all other phases

---

## Phase 2 — Solo Core

**Deliverable:** User completes onboarding, gets a Persona, browses Hidden Spots on an offline-capable map. The core solo value prop is usable end-to-end.

**Detailed plan:** Write when Phase 1 is merged. Key tasks:

- [ ] `persona.dart` — Isar collection with 5 float fields (Stamina, Curiosity, SolitudeNeed, NatureAffinity, CulturalAffinity) + `fromSliders` constructor
- [ ] `persona_provider.dart` — `AsyncNotifier` reading/writing Persona from Isar
- [ ] `onboarding_screen.dart` — 5 sliders (0.0–1.0), "Start Discovery" writes Persona, marks onboarding complete, navigates to Home
- [ ] `spot.dart` — Isar collection: id, name, lat, lng, osmTags (List<String>), tagDensity (int), personaScore (double)
- [ ] `osm_downloader.dart` — download OSM PBF for a bounding box, parse with `xml` or `osmfilter` subprocess, write natural features to Isar
- [ ] `serendipity_scraper.dart` — query Isar spots where `tagDensity < threshold`, score against active Persona vector (dot product), return ranked list
- [ ] `tile_cache_manager.dart` — configure `flutter_map_tile_caching` with OSM + OpenTopoMap stores
- [ ] `explore_screen.dart` — `FlutterMap` with cached tile layer + spot pins; bottom sheet list sorted by persona score
- [ ] Journey-based tile download prompt: when user sets a destination, compute bounding box, show "Download ~NMB for offline use?" dialog
- [ ] Golden path: onboard → see Hidden Spots on map → put device in airplane mode → spots and map still visible

**Depends on:** Phase 1
**Unlocks:** Phase 3

---

## Phase 3 — Journey

**Deliverable:** User starts a Journey, navigates to a Spot, receives a Task, completes it, adds a Journal Entry, ends the Journey. The full solo loop works offline.

**Detailed plan:** Write when Phase 2 is merged. Key tasks:

- [ ] `journey.dart` — Isar collection: id, startTime, endTime, trackPoints (List<LatLng>), spotIds (List<String>), taskIds (List<String>), weatherSnapshot (String JSON), totalDistanceM (double)
- [ ] `gps_tracker.dart` — `location` package stream → appends LatLng to active journey, computes running distance
- [ ] `journey_provider.dart` — `Notifier` managing active Journey state: start, addTrackPoint, addSpot, end
- [ ] `journey_screen.dart` — turn-by-turn overlay on `FlutterMap`, next stop card, distance/time/elevation footer
- [ ] `task_template.dart` — Dart model for `assets/tasks/library.json` entries: id, title, description, type (sound/sketch/tactile/reflective), requiredOsmTags, personaAffinities, weatherConditions, durationSeconds
- [ ] `assets/tasks/library.json` — 80 curated task templates (hand-written, culturally reviewed)
- [ ] `task_provider.dart` — given current Spot's OSM tags + active Persona + weather, filter library, rank by affinity, return top 3
- [ ] `task_screen.dart` — "Accept Task" card, countdown timer, type-specific capture UI (audio waveform / sketch canvas / text reflection)
- [ ] `audio_recorder.dart` — wraps `record`: start, stop, return file path; used by Sound tasks
- [ ] `task.dart` — Isar collection: templateId, journeyId, spotId, completedAt, captureFilePath
- [ ] `journal_entry.dart` — Isar collection: id, journeyId (nullable), type, content (text or file path), lat, lng, createdAt
- [ ] `journal_screen.dart` — filterable list (All / Tasks / Places / Thoughts), entry detail view
- [ ] Golden path: start journey → navigate to spot → accept task → record audio → complete task → add text reflection → end journey → see it in journal

**Depends on:** Phase 2
**Unlocks:** Phase 4 (Anshin, Persona learning), Phase 5 (Group)

---

## Phase 4 — Safety & Intelligence

**Deliverable:** Anshin Engine warns users of hazards before and during journeys. Persona starts updating from journey history after 5 completed journeys.

**Detailed plan:** Write when Phase 3 is merged. Key tasks:

- [ ] `forecast_cache.dart` — fetch 48h forecast from Open-Meteo (free, no key) for journey bounding box center, store as JSON in Isar with `cachedAt` timestamp; display staleness warning if > 6h old
- [ ] `hazard_overlay.dart` — load `assets/hazards/hazard_zones.geojson` as a `PolygonLayer` on the journey map; OSM government dataset sourced statically
- [ ] `anshin_engine.dart` — `StreamProvider` merging forecast JSON + hazard geometry + `sensors_plus` barometer (pressure drop < -2 hPa/h = alert); emits `AnshinAlert` events
- [ ] Alert UI in `journey_screen.dart` — red banner with alert type + "View New Route" / "Not Now" actions; rerouting is a re-run of Serendipity Scraper with Anshin constraints added
- [ ] TFLite persona model — train offline (Python script in `tools/train_persona_model.py`) on synthetic journey→persona delta data; export as `assets/ml/persona_updater.tflite`
- [ ] `persona_provider.dart` update — after each Journey completion, if `completedJourneys >= 5`, run TFLite inference: input = last 5 journey feature vectors (spots chosen, tasks completed, distance, duration), output = persona delta; apply delta with learning rate 0.1
- [ ] Opt-in LLM: integrate `flutter_gemma` (TinyLlama 1.1B, ~650MB); gated behind Settings toggle "Richer task descriptions"; model downloaded on first toggle-on; task description rewrite prompt: `"Rewrite this task description for a hiker at [spot_name] in [weather] at [time_of_day]: [template_description]"` max 40 tokens
- [ ] Golden path: download forecast before trip → enter airplane mode → trigger Anshin alert (mock pressure drop in debug) → see reroute suggestion → complete 5 journeys → check persona has shifted

**Depends on:** Phase 3
**Unlocks:** Phase 5 (Group uses Persona), Phase 6

---

## Phase 5 — Group

**Deliverable:** A Host creates a Group via BLE, members join, Merged Persona is computed, group sees a shared offline itinerary.

**Detailed plan:** Write when Phase 4 is merged. Key tasks:

- [ ] `group.dart` — in-memory model (not persisted): hostId, members (List<MemberPersona>), mergedPersona, status (forming/active/dissolved)
- [ ] `ble_scanner.dart` — advertise: `flutter_blue_plus` peripheral mode broadcasting service UUID `zen-group-v1` + hostId; scan: discover nearby devices advertising same UUID
- [ ] Host flow: "Start Group" → advertise → see join requests → approve/deny each → broadcast merged state
- [ ] Member flow: scan → see nearby groups → request join → wait for host approval → receive merged state
- [ ] Gossip protocol: on member approval, host writes `GroupState` (member list + merged persona) to a shared GATT characteristic; each member reads it on connection; re-broadcast on each new approval (max 6 members = convergence in < 3 rounds)
- [ ] `group_provider.dart` — `Notifier` managing `group.dart` state machine; exposes `mergedPersona` which overrides solo Persona in Serendipity Scraper and Task Weaver when Group is active
- [ ] Merged Persona calculation: min(Stamina, SolitudeNeed, CulturalAffinity) across members; avg(Curiosity, NatureAffinity) across members
- [ ] `group_screen.dart` — member avatars in mesh layout (see mockup), Group Harmony bar, "View Group Itinerary" CTA
- [ ] Group itinerary = Serendipity Scraper run against Merged Persona, formatted as timeline (see mockup screen 6)
- [ ] Golden path: two simulator instances (or two devices) form a group → merged persona visible → group itinerary generated → both see same spots

**Depends on:** Phase 3 (Journey), Phase 4 (Persona inference)
**Unlocks:** Phase 6

---

## Phase 6 — Community

**Deliverable:** User optionally creates a Community Account, posts a Journey moment to the feed, browses For You / Following / Nearby tabs. Badges and journey history are complete.

**Detailed plan:** Write when Phase 5 is merged. Key tasks:

- [ ] Supabase project setup: enable PostGIS, create `posts` table (id, user_id, content, media_url, place_name, lat_fuzzy, lng_fuzzy, created_at), `follows` table, Storage bucket `post-media`, RLS policies (users read own + public posts, write own only)
- [ ] `community_account.dart` — Supabase magic-link auth; only initializes `Supabase.instance` here, nowhere else in the app; account creation prompted only on first "Share to Feed" tap
- [ ] `post.dart` — Dart model mapping to Supabase `posts` row; lat/lng stored as fuzzy (rounded to 2 decimal places ≈ 1km); exact coordinates never serialized
- [ ] `feed_provider.dart` — `AsyncNotifier` with three query modes: For You (recency + following), Following (followed users), Nearby (PostGIS `ST_DWithin` on fuzzy coords, 10km radius)
- [ ] `feed_screen.dart` — tab bar (For You / Following / Nearby), post cards with place name + media + like/comment counts (see mockup screen 13)
- [ ] Share flow: from Journey detail or Journal Entry → "Share to Feed" → prompts account creation if needed → compose screen (content text, media attach, place name pre-filled, fuzzy location shown) → post
- [ ] `badges_screen.dart` — Achievement Badges grid (see mockup screen 11); badge definitions in `assets/badges/definitions.json`; XP computed from: journey count × 10 + task completions × 5 + distance km × 2; milestone badges at 10/25/50/100 journeys
- [ ] Journey history screen (mockup screen 12) — filterable list (All/Past/Completed/Saved), aggregate stats header (total journeys, km, hours, places)
- [ ] Golden path: complete a journey → share to feed → view it in Nearby tab → earn a badge → see XP update

**Depends on:** Phase 5
**Unlocks:** shipped

---

## Build Order Summary

```
Phase 1 (Foundation)
  └─ Phase 2 (Solo Core: Persona + Maps + Spots)
       └─ Phase 3 (Journey: GPS + Tasks + Journal)
            ├─ Phase 4 (Safety: Anshin + Persona Learning + LLM)
            │    └─ Phase 5 (Group: BLE Mesh)
            │         └─ Phase 6 (Community: Feed + Badges)
            └─ Phase 5 can start in parallel with Phase 4
               if two engineers are available
```

## Per-Phase Detailed Plans

Each phase gets its own plan written immediately before implementation begins. Do not write Phase N+1's detailed plan until Phase N is tested and merged — requirements shift.

| Phase | Plan file (create when ready) |
|---|---|
| 1 | `docs/superpowers/plans/2026-07-03-phase-1-foundation.md` |
| 2 | `docs/superpowers/plans/YYYY-MM-DD-phase-2-solo-core.md` |
| 3 | `docs/superpowers/plans/YYYY-MM-DD-phase-3-journey.md` |
| 4 | `docs/superpowers/plans/YYYY-MM-DD-phase-4-safety-intelligence.md` |
| 5 | `docs/superpowers/plans/YYYY-MM-DD-phase-5-group.md` |
| 6 | `docs/superpowers/plans/YYYY-MM-DD-phase-6-community.md` |
