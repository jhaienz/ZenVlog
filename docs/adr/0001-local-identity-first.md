---
status: superseded by ADR-0007
---

# Local identity first, Community Account optional

The app's core promise is that personal data never leaves the device. Requiring a Supabase account at first launch contradicts this — it forces a network call, creates a server-side record, and implies data ownership by ZenVlog before the user has agreed to anything. We generate a local UUID on first launch instead. All Solo and Group functionality works indefinitely on this identity. A Community Account (Supabase Auth) is created only when the user first interacts with the feed. This is hard to reverse: the data model, onboarding flow, and privacy guarantee are all built on the assumption that an account is never required.

## Considered options

- **Supabase Auth on first launch** — simpler identity model, but breaks offline onboarding and the privacy pitch.
- **Anonymous Supabase Auth upgraded later** — still initializes the Supabase client on cold start; same problem.
