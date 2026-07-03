# Phase 4 — Safety & Intelligence: Results

**Status:** ✅ Complete

## What was implemented

| Component | File | Notes |
|---|---|---|
| ForecastCache | `lib/features/anshin/forecast_cache.dart` | 48h Open-Meteo forecast, Isar singleton row, 6h staleness threshold, keeps stale cache on failed refresh |
| AnshinAlert | `lib/features/anshin/anshin_alert.dart` | Types: weather / hazard / barometer / staleData; severities: warning / danger |
| HazardOverlay | `lib/features/anshin/hazard_overlay.dart` | Bundled GeoJSON zones (Bicol River flood plain seeded), map polygons + position check |
| AnshinEngine | `lib/features/anshin/anshin_engine.dart` | Riverpod stream: rain >70% within 6h, stale-data warning, hazard zone entry, barometer drop >2 hPa |
| Alert banner | `lib/features/journey/journey_screen.dart` | Worst-severity alert above map; hazard polygons rendered on journey map |
| Pre-trip prompt | `lib/features/explore/explore_screen.dart` | "Download Safety Data" dialog when forecast missing/stale, before journey starts |
| PersonaLearning | `lib/features/persona/persona_learning.dart` | EMA (lr 0.1) after 5 journeys: distance→stamina, task engagement→nature+curiosity, early starts→solitude |
| Journey-end hook | `lib/features/persona/persona_provider.dart` | `recordCompletedJourney` counts journeys + applies learning |
| Settings screen | `lib/features/profile/settings_screen.dart` | LLM toggle (persisted); Profile now links to Settings |
| LlmRewriter seam | `lib/features/tasks/llm_rewriter.dart` | Wired into task screen; returns curated text until a model ships |

## Test results

| Test | Result |
|---|---|
| forecast staleness (2 tests) | ✅ |
| rainAlertHours detection (2 tests) | ✅ |
| hazard zone inside/outside (2 tests) | ✅ |
| persona learning: gate below 5 journeys | ✅ |
| persona learning: stamina up on long journeys | ✅ |
| persona learning: stamina down on short journeys | ✅ |
| persona learning: nature affinity from task completion | ✅ |
| persona learning: clamped to [0,1] | ✅ |
| Full suite (25 tests) | ✅ exit 0 |
| `flutter analyze` | ✅ No issues |
| `flutter build apk --debug` | ✅ Builds |

## Deviations from plan

1. **No TFLite** — plan's model was to be trained on *synthetic data encoding hand-written rules*, so the rules ship directly as `PersonaLearning` (Dart EMA). Kills the AGP 9 duplicate-namespace blocker, the Python training script, the model asset, and a native dependency. Revisit real ML when real usage data exists.
2. **flutter_gemma not integrated** — needs manual model provisioning (HF token, ~650MB) and the test device (SM A065F) is low-RAM. `LlmRewriter` seam + settings toggle shipped; integrating a model later touches one method. ADR-0005 already required curated text as the always-working path.
3. **sensors_plus 4.x → 6.x** — 4.x has no barometer API.
4. **Hazard check is bbox, not point-in-polygon** — fine for rectangular zones; ponytail note marks the ray-casting upgrade path.
5. **Reroute action deferred** — plan's "View New Route" banner button did nothing (rerouting = re-run scraper, no route engine exists yet). Banner shows the alert; rerouting belongs with a real routing feature.

## Known ceilings (ponytail notes)

- Hazard zones: one seeded flood plain for the Naga test region; real datasets are content work.
- Barometer sampling window is event-count-based, not time-based; fine for the alert's purpose.
- Anshin alerts recompute per journey screen build; no background monitoring when app is closed.
