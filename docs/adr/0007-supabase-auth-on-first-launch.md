---
status: accepted
---

# Supabase Auth required at first launch

Supersedes ADR-0001. A single Supabase account is now the user's identity across all three modes, created via email sign-in on first launch before onboarding. This trades the offline-first onboarding and "no account ever required" guarantee for one identity model: no local-UUID-to-account migration, one user id everywhere (Group sync, feed, future features). Personal data (persona, journeys, journal) still lives only in Isar on-device; the account holds credentials and, later, feed posts — signing in does not upload anything.

## Consequences

- First launch requires an internet connection. After the first sign-in the cached session works offline indefinitely.
- `LocalIdentity` (device UUID) is deleted; the Supabase user id replaces it everywhere the phase plans reference `LocalIdentity.current`.
- Phase 6's lazy Supabase initialization is obsolete — the client initializes in `main()`.
