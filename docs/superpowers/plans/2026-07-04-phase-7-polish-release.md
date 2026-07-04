# Phase 7 — Polish, Real BLE, LLM, Release Prep

**Goal:** Close the deferred items from Phases 1–6 and make the app releasable: share-to-feed hook, follow UI, media picker, 80-task library, Overpass caching, real BLE advertising, on-device LLM in the rewriter seam, release signing + icon + Supabase setup guide.

## Task A: Polish + loose ends

- [ ] Share-to-feed hook: journey end dialog gains "Share to Feed" → pushes compose with place/lat/lng query params (fuzzy applied at post time)
- [ ] Follow/unfollow: button on post cards. Prod: insert/delete in `follows`. Dev: local in-memory set. Following tab filters by it in dev too.
- [ ] Media picker: `image_picker`, attach photo in compose. Dev: shown locally only. Prod: uploads to `post-media`.
- [ ] Task library 20 → 80 entries (same 4 types, richer tag coverage)
- [ ] Overpass per-bbox caching: skip network when cached spots for the bbox are < 7 days old (Spot gains fetchedAt; bbox key rounded to 0.1°)

## Task B: Real BLE group sync

- [ ] Add `bluetooth_low_energy` package
- [ ] BleTransport.startAdvertising → real PeripheralManager advertising `ZenGroup:<id>` + GATT characteristic serving group state JSON
- [ ] Join flow: central connects, reads state characteristic, writes join request
- [ ] Verify: compiles on AGP 9, unit test for state codec. Over-the-air join needs 2 devices — document as on-device verification.

## Task C: On-device LLM rewriter

- [ ] Try ffi-based runtime first (no AAR namespace risk on AGP 9): `llama_cpp_dart` or similar; fallback candidates flutter_gemma / MediaPipe GenAI
- [ ] Model: smallest viable instruct model (Qwen2.5-0.5B / Gemma-2b int4), downloaded on first enable (opt-in already in Settings), never bundled
- [ ] Wire into LlmRewriter.rewrite behind existing enabledKey toggle; template passthrough stays the fallback
- [ ] If AGP 9 / device constraints block: document, keep seam, ship rules passthrough

## Task D: Release prep

- [ ] `docs/SUPABASE_SETUP.md`: project creation, run migration, bucket, env.dart fill, prod build command
- [ ] Release signing: keystore instructions, `key.properties` (gitignored), signingConfig in build.gradle.kts
- [ ] App icon + splash: flutter_launcher_icons + flutter_native_splash, forest-green/gold mark
- [ ] `flutter build apk --release` succeeds (dev env)
- [ ] Results doc `docs/results/phase-7-polish-release.md`

Order: A → B → C → D. Commit per feature. Full suite + analyze green before each commit.
