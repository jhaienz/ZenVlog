# Phase 6 — Community: Results

**Status:** ✅ Complete (prod feed needs your Supabase project — see deviations)

## What was implemented

| Component | File | Notes |
|---|---|---|
| Supabase schema | `supabase/migrations/0001_initial.sql` | PostGIS, posts + follows tables, RLS, fuzzy-coord trigger, indexes |
| Post model | `lib/features/community/post.dart` | Fuzzy coords only (2 decimals ≈ 1km); exact GPS never serialized |
| FeedNotifier | `lib/features/community/feed_provider.dart` | For You / Following / Nearby; dev = in-memory fake feed, prod = Supabase |
| Feed screen | `lib/features/community/feed_screen.dart` | 3 tabs, post cards, FAB compose |
| Compose screen | `lib/features/community/compose_post_screen.dart` | Text post, place prefill via query params, "~1km approximate" notice |
| BadgesProvider | `lib/features/profile/badges_provider.dart` | XP = journeys×10 + tasks×5 + km×2; level per 500 XP; milestones 10/25/50/100 |
| Badge definitions | `assets/badges/definitions.json` | 5 achievements + 4 milestones |
| Badges screen | `lib/features/profile/badges_screen.dart` | Level header, XP bar, earned/locked grid |
| Journey history | `lib/features/profile/journey_history_screen.dart` | Totals bar (journeys/km/hours) + per-journey list from Isar |
| Profile screen | `lib/features/profile/profile_screen.dart` | Real content: level, XP, badges/history/settings links |
| Routes | `lib/app/router.dart` | /community, /community/compose, /profile/badges, /profile/history |
| Home card | `lib/features/home/home_screen.dart` | Community Feed entry card |

## Test results

| Test | Result |
|---|---|
| XP formula: journeys×10 + tasks×5 + distance×2 | ✅ |
| Milestone badge at 10 journeys (not 25) | ✅ |
| No milestone badges below 10 journeys | ✅ |
| All 4 milestones at 100 journeys | ✅ |
| Full suite (36 tests) | ✅ exit 0 |
| `flutter analyze` | ✅ No issues |
| `flutter build apk --debug` | ✅ Builds |

## Deviations from plan

1. **CommunityAccount dropped** — plan predates ADR-0007. Auth already exists app-wide (`AuthService`, email + password, initialized at launch in prod). No lazy Supabase init, no magic-link sign-in screen; feed uses the same session.
2. **Dev fake feed** — dev builds have no Supabase keys, so `FeedNotifier` serves an in-memory fake feed (3 seeded posts, all tabs identical; your own posts append). Real fetching/posting is the prod path.
3. **Migration not applied** — needs your Supabase project. Run `supabase/migrations/0001_initial.sql` in the SQL Editor and create a public `post-media` bucket (10MB; jpeg/png/m4a) before first prod feed use.
4. **Badges trimmed to computable** — dropped `solo_seeker` (journeys don't record solo vs group) and `hidden_finder` (no per-spot discovery counter). Added `mindful_creator` via sketch-task count. 9 badges ship.
5. **Nearby tab is recency-ordered geo-tagged posts** — ponytail note in code: st_dwithin RPC when real distance filtering matters.
6. **nav_shell test reduced to tab presence** — Isar queries and rootBundle loads never complete under the fake-async widget-test binding in this environment (verified: plain test binding completes the same query instantly; a pending query also hangs Isar close in teardown). Tab navigation is exercised on-device. Not a Phase 6 regression — reproduced at the Phase 5 commit.

## Golden path (single device, dev build)

1. Home → Community Feed → For You shows 3 seeded posts
2. FAB + → write text → Post → appears in feed
3. Complete a journey (Explore → spot → Start Journey → task → End)
4. Profile → level/XP shown; Badges & Achievements → "First Steps" earned
5. Profile → Journey History → totals + journey row

## Known ceilings (ponytail notes)

- Dev feed is in-memory; restart clears your posts.
- Media upload path exists in `createPost` (prod only, `post-media` bucket) but no picker UI yet.
- Follows table + RLS shipped; no follow/unfollow UI — Following tab empty until that lands.
- No share-to-feed hook from journey end; compose is reachable from the feed FAB (place/lat/lng query params ready for the hook).
