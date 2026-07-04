# Phase 5 — Group: Results

**Status:** ✅ Complete (BLE transport partially stubbed — see deviations)

## What was implemented

| Component | File | Notes |
|---|---|---|
| Group domain | `lib/features/group/group.dart` | In-memory Group + MemberPersona, max 6, status forming/active/dissolved |
| Merged Persona | `Group.computeMergedPersona` | ADR-0004: min(Stamina, SolitudeNeed, CulturalAffinity), avg(Curiosity, NatureAffinity) |
| Harmony score | `Group.harmonyScore` | 1 − avg pairwise squared distance across persona vectors |
| BLE transport | `lib/features/group/ble_transport.dart` | Scanning real (flutter_blue_plus); advertising/GATT stubbed |
| GroupNotifier | `lib/features/group/group_provider.dart` | Host lifecycle, member approval, dev addTestMember |
| Group screen | `lib/features/group/group_screen.dart` | Harmony bar, member list, Start Group / Leave |
| Group itinerary | `lib/features/group/group_itinerary_screen.dart` | Timeline of top-5 spots ranked by Merged Persona, Start Journey |
| Home screen | `lib/features/home/home_screen.dart` | Entry cards: Explore / Group Sync / Journal (was placeholder) |
| Permissions | `AndroidManifest.xml` | BLUETOOTH_SCAN / CONNECT / ADVERTISE |

## Test results

| Test | Result |
|---|---|
| merge: min for constraints, avg for preferences | ✅ |
| single-member merge = own persona | ✅ |
| harmony 1.0 for identical personas | ✅ |
| harmony drops for divergent personas | ✅ |
| copyWith recomputes merged persona | ✅ |
| Full suite (30 tests) | ✅ exit 0 |
| `flutter analyze` | ✅ No issues |
| `flutter build apk --debug` | ✅ Builds |

## Deviations from plan

1. **Plan's BLE code was unimplementable** — `FlutterBluePlus.startAdvertising` and GATT-server hosting don't exist; flutter_blue_plus is central-only. Advertising + group-state characteristic are stubbed behind `BleTransport` with a ponytail note: wire the `bluetooth_low_energy` package's PeripheralManager when two test devices exist (join flow is unverifiable on one device regardless).
2. **Dev test members** — `addTestMember` fabricates members with random personas so merge, harmony, and itinerary are exercisable on a single device.
3. **No scraper override param** — plan wanted `findHiddenSpots(persona, {overridePersona})`; the itinerary just passes the Merged Persona as the ranking persona. The param was redundant.
4. **Gossip protocol not built** — depends on the stubbed GATT layer; single-round host-broadcast design documented in the roadmap for when transport lands.

## Golden path (single device, dev build)

Home → Group Sync → Start Group → Add test member ×3 → harmony bar moves → View Group Itinerary → spots ranked by merged persona (low-stamina member visibly drags ranking toward gentler spots) → Start Journey.

## Known ceilings (ponytail notes)

- `BleTransport.startAdvertising` is a local flag — no over-the-air discovery until peripheral support lands.
- Host approval UI exists in provider (`approveMember`) but no incoming-request surface until transport is real.
