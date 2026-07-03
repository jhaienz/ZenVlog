# ZenVlog

A privacy-first outdoor mindfulness app. All personal data lives on-device. Users move between three modes — Solo, Group, and Community — within a single account-optional identity model.

## Language

### Identity & Modes

**Mode**:
One of three states a user operates in: Solo (offline, private), Group (offline, BLE-coordinated), or Community (online, social). A single user can move between all three; modes are not roles.
_Avoid_: Role, state, view, user type

**Local Identity**:
A UUID generated on first launch that identifies the user on-device. No account required. Upgraded to a Community Account only when the user opts into the feed.
_Avoid_: Anonymous user, guest, device ID

**Community Account**:
A Supabase-backed identity created only when the user first posts to or browses the community feed. Holds no journey, persona, or journal data.
_Avoid_: Account, user account, profile

### Persona & Discovery

**Persona**:
A 5-dimension vector (Stamina, Curiosity, Solitude Need, Nature Affinity, Cultural Affinity) representing a user's outdoor character. Initialized from onboarding sliders; refined over time by on-device behavioral inference from journey history.
_Avoid_: Profile, preferences, user settings

**Merged Persona**:
The group-level persona vector computed from all members' Personas. Constraints (Stamina, Solitude Need, Cultural Affinity) use the minimum across members; preferences (Curiosity, Nature Affinity) use the average.
_Avoid_: Group profile, combined preferences, shared persona

**Hidden Spot**:
A natural feature present in offline OSM data but carrying few or no tourism, amenity, or popularity tags. Surfaced by the Serendipity Scraper and ranked by distance and Persona match.
_Avoid_: POI, point of interest, location, waypoint, secret spot

**Serendipity Scraper**:
The on-device discovery engine. Filters downloaded OSM data for Hidden Spots and ranks them against the active Persona (or Merged Persona in Group mode).
_Avoid_: Recommendation engine, discovery engine, AI finder

### Trips & Content

**Journey**:
The container entity for a single outdoor trip: GPS track, start/end timestamps, weather snapshot, list of Spots visited, and Tasks completed. Parent of Journal Entries.
_Avoid_: Trip, hike, outing, adventure, excursion

**Journal Entry**:
A piece of content (text reflection, audio recording, photo, or sketch) created during or after a Journey. Belongs to a Journey via a nullable `journeyId` — can exist without one.
_Avoid_: Log entry, note, memory, post, record

**Task**:
A mindful micro-challenge assigned at a Spot during a Journey. Drawn from a curated library of templates (sound, sketch, tactile, reflective) and optionally described by an on-device LLM.
_Avoid_: Challenge, activity, mission, quest

**Spot**:
A specific Hidden Spot (or any named place) visited during a Journey, at which one or more Tasks may be assigned.
_Avoid_: Location, waypoint, stop, place

### Safety & Group

**Anshin Engine**:
The offline safety subsystem. Monitors a pre-cached weather forecast, static hazard overlays (flood zones, exposed ridgelines), and optional barometer pressure trends to issue alerts and suggest route changes.
_Avoid_: Safety monitor, safety system, alert engine

**Group**:
A temporary set of 2–6 users connected via BLE during a shared Journey. Formed by host broadcast and explicit member approval. Dissolved when the Journey ends.
_Avoid_: Party, team, squad, crew

**Host**:
The Group member who initiated the BLE broadcast and approves join requests. Holds no special authority over the itinerary beyond formation.
_Avoid_: Leader, admin, organizer
