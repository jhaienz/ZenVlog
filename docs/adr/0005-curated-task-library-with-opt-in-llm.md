# Tasks use a curated library; LLM flavor text is opt-in

Task generation has two requirements in tension: cultural safety (tasks must be reviewed for local sensitivity) and contextual richness (tasks should feel specific to the exact spot, weather, and time). A curated library of ~80 hand-written templates satisfies the first requirement: every task is reviewed before it ships. An opt-in on-device LLM (downloaded on first request, ~650MB) satisfies the second: it rewrites the template's description sentence using the current spot name, weather, and time of day as context. The LLM layer is purely cosmetic — it cannot change task type, duration, or requirements, only the descriptive framing. Users without the LLM download get the library description unchanged; no feature is gated on it.

## Considered options

- **LLM required** — richer output but adds a mandatory ~650MB download, excludes low-storage or low-RAM devices, and removes cultural review from the generation path.
- **Pure rule-based** — simplest, but task descriptions become formulaic after a few journeys.
