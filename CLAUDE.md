# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ZenVlog** ("The Silent Synergy Journal") is a privacy-first outdoor mindfulness mobile app. No stack has been chosen yet — the repo currently contains only UI/UX mockups in `MOCKUP/`.

Core philosophy: **offline-first, on-device AI, no cloud data egress.**

## Key Feature Modules (from mockups)

| Module | Description |
|---|---|
| Edge-AI Persona Profiler | On-device ML builds a radar-chart persona (Stamina, Curiosity, Solitude Need, Nature Affinity, Cultural Affinity). 100% local, no cloud. |
| Serendipity & Solitude Scraper | Finds unmapped/hidden spots using offline topo + satellite + historical data, matched to user's isolation level. |
| Contextual Task Weaver | Generates mindful micro-tasks (sound recording, sketch challenges, stone arrangement) scoped to current location. |
| Mesh-Network Preferences Syncer | Syncs group preferences peer-to-peer over Bluetooth Mesh — no internet required. |
| Anshin Engine (Safety Monitor) | Real-time offline safety: weather alerts, trail condition scan, dynamic route rerouting. |
| Journal & Memories | Fully on-device journal: tasks, places, reflections, audio recordings, photos. |
| Badges & Achievements | XP + milestone system tied to journey completions and task types. |
| Feed & Community | Optional social layer: share moments, follow others, proximity feed. |

## Navigation Structure

Bottom tab bar: **Home · Explore · Journal · Profile**

Secondary (AI-focused) nav: **Journeys · AI Engine · Explore · Community · Profile**

## Design Language

Dark forest-green primary (`~#1a3a2a`), cream/beige content cards, amber/gold accents. Nature photography as hero imagery. Minimalist iconography.

## Domain Model & Decisions

- `CONTEXT.md` — canonical glossary (Persona, Journey, Hidden Spot, Task, Anshin Engine, etc.). Use these terms exactly; see _Avoid_ lists for banned synonyms.
- `docs/adr/` — 6 ADRs covering the non-obvious architectural decisions. Read before touching identity, safety, spot discovery, group sync, tasks, or backup.

## Architecture Constraints

- All AI/ML inference must run on-device (no server calls for persona or recommendations).
- Offline maps: topo + satellite tiles must be downloadable for offline use.
- Bluetooth Mesh for group sync — design around BLE limitations (range, peer discovery).
- Journal data never leaves the device unless the user explicitly shares to the feed.
