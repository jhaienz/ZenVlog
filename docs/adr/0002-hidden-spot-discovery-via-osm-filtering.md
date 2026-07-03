# Hidden Spot discovery via low-tag OSM filtering

"Hidden" means hidden from other apps, not absent from map data. OSM already contains vast amounts of natural geometry (streams, clearings, groves) that carries no tourism, amenity, or popularity tags — these features are invisible to apps that filter for named, tagged, or reviewed places. The Serendipity Scraper exploits this gap: it downloads the OSM region for the user's area, filters for natural features below a tag-density threshold, and ranks results by distance and Persona match. This runs entirely on-device with no network dependency after the initial OSM download.

## Considered options

- **Satellite imagery ML** — finds truly unmapped features but requires on-device computer vision (large model, slow inference, unreliable on mid-range hardware). Out of scope for v1.
- **Community-sourced spots** — spots logged by other ZenVlog users. Requires the backend to be functional; breaks offline-first and creates a chicken-and-egg problem at launch.
