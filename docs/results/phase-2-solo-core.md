# Phase 2 — Solo Core: Results

**Status:** ✅ Complete
**Commits:** `c175509` → `dc15768`

## What was implemented

| Component | File | Notes |
|---|---|---|
| Persona model | `lib/features/persona/persona.dart` | Isar collection, 5-dim vector (Stamina, Curiosity, Solitude Need, Nature Affinity, Cultural Affinity) |
| PersonaProvider | `lib/features/persona/persona_provider.dart` | AsyncNotifier; save() clears onboarding gate |
| Onboarding | `lib/features/onboarding/onboarding_screen.dart` | 5 sliders → Persona; router redirect gates until Persona exists |
| Spot model | `lib/features/explore/spot.dart` | osmId (unique index), tags, tagDensity, personaScore |
| Serendipity Scraper | `lib/features/explore/serendipity_scraper.dart` | Hidden = `tagDensity < 4`; stamina-constrained ranking |
| OSM downloader | `lib/features/explore/osm_downloader.dart` | Overpass API, natural features (water/wood/peak/grassland/cliff/cave) |
| Tile cache | `lib/core/maps/tile_cache_manager.dart` | FMTC + ObjectBox backend, OSM tiles cached for offline |
| Explore screen | `lib/features/explore/explore_screen.dart` | GPS-centered map (Tokyo fallback), auto OSM download on first visit, ranked pins + card list |

## Test results

| Test | Result |
|---|---|
| `persona_test.dart` — fromSliders sets all fields | ✅ |
| `persona_test.dart` — vector order correct | ✅ |
| `serendipity_scraper_test.dart` — tagDensity ≥ 4 excluded | ✅ |
| `serendipity_scraper_test.dart` — low-stamina user: water ranks above peak | ✅ |
| `nav_shell_test.dart` — no-persona → onboarding redirect | ✅ |
| Full suite (10 tests) | ✅ All pass |
| `flutter analyze` | ✅ No issues |
| `flutter build apk --debug` | ✅ Builds |

## Deviations from plan

1. **Scoring algorithm changed** — the plan's plain dot product ranked a peak above a stream for a low-stamina user (its own test caught this). New scoring: stamina acts as a constraint (scales tag score by fit `1 - max(0, demand - stamina)`), the other 4 dimensions accumulate as preferences. Mirrors ADR-0004's min/avg philosophy.
2. **OsmDownloader wired to Explore screen** — the plan defined it but never called it; it now triggers when the Spot collection is empty.
3. **Onboarding gate** — implemented as a static `OnboardingGate.needed` flag checked in the router redirect, instead of the plan's GoRouter-rebuild approach.
4. **Missing `package:isar` imports in plan code** — extension methods (`findFirst`, etc.) need the direct import; plan omitted it in providers/main.
5. **`PersonaNotifier.update` deleted** — collided with Riverpod's built-in `AsyncNotifier.update`.
6. **Analyzer excludes `**/*.g.dart`** — Isar generates experimental-API warnings.

## Known ceilings (ponytail notes)

- `OsmDownloader` caches a single region (no-op if any Spots exist) — per-bbox coverage tracking when multi-region support matters.
- Spot download bbox is ±0.1° (~11 km) around map center.
