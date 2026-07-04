# Phase 7 — Polish, Real BLE, LLM, Release Prep: Results

**Status:** ✅ Complete (BLE OTA join + LLM inference need on-device verification)

## What was implemented

### A. Polish
| Item | Detail |
|---|---|
| Share-to-feed hook | Journey End → dialog → compose prefilled with spot name + coords (fuzzied at post time) |
| Follow/unfollow | Button on post cards; `FollowsNotifier` (prod: `follows` table, dev: local set); Following tab filters in both |
| Media picker | `image_picker` in compose, preview + remove; prod uploads to `post-media`; dev preview-only |
| Task library | 20 → **80** entries; tag coverage widened (beach, sand, spring, wetland, scrub, heath, ridge, valley, tree, bare_rock, bay) |
| Overpass bbox cache | Network skipped when cached spots inside the bbox are < 7 days old |

### B. Real BLE group sync
| Item | Detail |
|---|---|
| Host advertising | `bluetooth_low_energy` PeripheralManager: `ZenGroup:<hostId>` + group service UUID |
| GATT state | State characteristic serves live group JSON per read; join requests arrive as writes → auto-approve up to 6 |
| Member join | "Join a Group nearby" dialog: scan → connect → read state → write join → local group set from host snapshot |
| Codec | `MemberPersona`/`Group` JSON round-trip, 2 new tests |

### C. On-device LLM
| Item | Detail |
|---|---|
| Runtime | `flutter_gemma` 1.2.0 + MediaPipe engine, initialized in `main` |
| Provisioning | Settings: model URL (Gemma3 1B int4 `.task` prefilled) + optional HF token, one-time download with progress |
| Rewriter | `LlmRewriter.rewrite` prompts with spot + time of day; curated text on any failure/disabled/missing model |
| AGP 9 fix | flutter_gemma skips `kotlin-android` on AGP 9 expecting built-in Kotlin, but the template sets `android.builtInKotlin=false` → its classes never compiled. Root build script now applies KGP to `flutter_gemma*` modules. |

### D. Release prep
| Item | Detail |
|---|---|
| Signing | `key.properties`-driven release signingConfig, debug-key fallback; keystore steps in `docs/RELEASE.md` |
| Icon + splash | Generated gold-leaf-on-forest-green branding (`assets/branding/`), `flutter_launcher_icons` + `flutter_native_splash` |
| R8 | MediaPipe proto keep/dontwarn rules (`proguard-rules.pro`) — release minify failed without them |
| Docs | `docs/SUPABASE_SETUP.md` (project → migration → bucket → env.dart → prod build), `docs/RELEASE.md` |

## Test results

| Check | Result |
|---|---|
| Full suite (38 tests) | ✅ exit 0 |
| `flutter analyze` | ✅ No issues |
| `flutter build apk --debug` | ✅ |
| `flutter build apk --release` | ✅ 185MB fat APK (use `--split-per-abi` / appbundle to distribute) |

## Needs on-device / two-device verification

- **BLE OTA join**: advertising + join flow compile and are wired end to end, but a real join needs two phones.
- **LLM inference**: model download + generation only runs on Android; SM A065F (4GB RAM) may be tight with Gemma3 1B — curated fallback covers failure.
- New app icon + splash visible on next install.

## Known ceilings (ponytail notes)

- Group members get a state snapshot at join — no live notify push of member-list changes yet.
- Nearby feed tab is recency-ordered geo-tagged posts, not distance-filtered.
- Dev feed still in-memory; photo attach in dev is preview-only.
