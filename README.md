# ZenVlog — The Silent Synergy Journal

> Mindful outdoor adventures. Fully offline. 100% private.

---

## The Problem

Outdoor apps today make two bad tradeoffs:

**1. Connectivity dependency.** Apps like AllTrails and Komoot require a data connection for maps, recommendations, and sync. In the mountains, you have none. You either pre-download and hope, or you're blind.

**2. Privacy erosion.** Every trail you walk, spot you visit, and preference you set is uploaded to a server, sold to advertisers, or handed to a data broker. "Outdoor wellness" apps have turned personal movement data into a product.

Beyond the infrastructure problems, there's a deeper UX failure: **outdoor apps optimize for the popular, not the personal.** They show you the same 10 crowded trails everyone else is on. They can't find the unnamed creek grove 2 km off-trail that perfectly matches your need for solitude. They don't adapt to who you are as an outdoor person.

Group coordination compounds this. Planning a hike with three friends means a WhatsApp thread, a Google Doc, and someone's hotspot dying at the trailhead.

---

## The Solution

ZenVlog is an offline-first mobile app that:

- **Learns your outdoor persona on-device.** A local ML model builds a profile (Stamina, Curiosity, Solitude Need, Nature Affinity, Cultural Affinity) from your behavior. No data leaves your phone.
- **Finds hidden spots, not popular ones.** The Serendipity Scraper cross-references offline topo maps, satellite imagery, and historical data to surface unmapped places that match your isolation level.
- **Gives you mindful micro-tasks.** Instead of just navigation, ZenVlog assigns contextual challenges at each spot — sound recordings, sketches, stone arrangements — to deepen engagement with the place.
- **Syncs groups without internet.** Bluetooth Mesh lets a group of hikers merge preferences and build a shared offline itinerary with no cell signal needed.
- **Monitors your safety, offline.** The Anshin Engine tracks weather, trail conditions, and visibility in real time, and reroutes you automatically when conditions deteriorate.
- **Keeps a private journal.** Every memory, task, photo, and recording stays on your device unless you explicitly share it.

---

## Tech Stack

### Mobile App — Flutter (Dart)

Single codebase for iOS and Android. Flutter's rendering engine and plugin ecosystem are the right fit for an app that needs custom map widgets, real-time BLE, and audio capture all in one place.

### On-Device AI — TensorFlow Lite (`tflite_flutter`)

The persona profiler and serendipity spot-matching run entirely on-device via TFLite. No cloud inference, no API calls. Models are bundled with the app and updated via app releases only.

### Local Database — Isar

Fast, Flutter-native embedded database for all local state: journeys, journal entries, discovered spots, persona vectors, task history, cached map metadata. Isar's zero-copy reads and reactive queries are well-suited to a heavy local-first data model.

### Offline Maps — `flutter_map` + `flutter_map_tile_caching`

`flutter_map` (open-source, Leaflet-based) renders the map. `flutter_map_tile_caching` handles bulk tile download for offline use. Tile sources:

| Layer | Source |
|---|---|
| Street / trail | OpenStreetMap |
| Topographic | OpenTopoMap |
| Satellite | Esri World Imagery (offline cache) |

No Mapbox or Google Maps — both require network-authenticated SDKs.

### State Management — Riverpod 2.x

`flutter_riverpod` with code generation (`riverpod_annotation`). The reactive provider model maps cleanly to the offline-first data flow: local DB → provider → UI, with BLE and safety engine events as async streams.

### Navigation — `go_router`

Official Flutter navigation package. Deep-link support for sharing spot/journey URLs in the community feed.

### Bluetooth Mesh — `flutter_blue_plus`

BLE scan/advertise for peer discovery. Group preference sync uses a simple gossip protocol over BLE GATT characteristics — no full BLE Mesh stack needed for syncing a handful of preference vectors. Each device re-broadcasts updated group state until convergence.

### Audio Recording — `record`

Cross-platform microphone capture for the Sound of Stillness task type. Outputs to local file, stored in Isar as a journal attachment.

### Community Feed Backend — Supabase

The only server-side component, and only used by the optional Feed & Community feature. Chosen because:

- **PostgreSQL + PostGIS** for geo-tagged post queries ("nearby" feed)
- **Realtime** for live feed updates
- **Storage** for community-shared photos
- **Auth** (magic link / OAuth) with row-level security so user data is isolated
- **Self-hostable** — aligns with the privacy posture; the backend can be run on-premise if needed

Personal data (journal, persona, journeys) is **never** sent to Supabase. Only content the user explicitly publishes to the feed touches the server.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                       │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐ │
│  │  Explore │  │ Journey  │  │  Journal / Tasks  │ │
│  │   (Map)  │  │  (Nav)   │  │                   │ │
│  └────┬─────┘  └────┬─────┘  └────────┬──────────┘ │
│       │              │                 │             │
│  ┌────▼──────────────▼─────────────────▼──────────┐ │
│  │              Riverpod Providers                 │ │
│  └────┬──────────┬──────────┬───────────┬─────────┘ │
│       │          │          │           │            │
│  ┌────▼───┐ ┌───▼────┐ ┌───▼───┐ ┌────▼────┐       │
│  │ Isar   │ │TFLite  │ │ BLE   │ │ Anshin  │       │
│  │  (DB)  │ │Persona │ │ Mesh  │ │ Engine  │       │
│  └────────┘ └────────┘ └───────┘ └────────┘       │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │         Offline Map Tile Cache               │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────┬───────────────────────┘
                              │ (feed only, opt-in)
                    ┌─────────▼──────────┐
                    │     Supabase       │
                    │  (community feed)  │
                    └────────────────────┘
```

**Data flow rule:** Everything flows through local Isar first. The Supabase client is only initialized when the user opens the Community tab. No background sync to server.

---

## Key Packages Summary

| Purpose | Package |
|---|---|
| UI framework | `flutter` (SDK) |
| State management | `flutter_riverpod`, `riverpod_annotation` |
| Navigation | `go_router` |
| Local database | `isar`, `isar_flutter_libs` |
| On-device ML | `tflite_flutter` |
| Maps | `flutter_map`, `flutter_map_tile_caching` |
| Bluetooth | `flutter_blue_plus` |
| Audio | `record` |
| Community backend | `supabase_flutter` |
| Code gen | `freezed`, `json_serializable`, `build_runner` |
| Secure local storage | `flutter_secure_storage` |

---

## Privacy Model

| Data type | Where it lives | Leaves device? |
|---|---|---|
| Persona / preferences | Isar (local) | Never |
| Journeys & navigation | Isar (local) | Never |
| Journal entries | Isar (local) | Never (unless shared) |
| Audio / photos | Local filesystem | Never (unless shared) |
| Community posts | Supabase | Only what user publishes |
| Account identity | Supabase Auth | Email only, for feed auth |
