# Data backup uses platform-native mechanisms, not ZenVlog-controlled storage

All personal data (Persona, Journeys, Journal Entries, Tasks) lives in Isar on-device. To recover it after device loss, we rely on iOS iCloud Backup and Android Auto Backup rather than building encrypted backup into Supabase Storage. This keeps ZenVlog servers entirely out of the personal data path — even encrypted, hosting user backups creates a legal discovery surface and a trust obligation we prefer not to hold. Platform-native backup is automatic, free to the user, and goes to their own cloud account. A manual ZIP export covers cross-platform migration (iOS → Android or vice versa).

## Consequences

Users who disable iCloud/Google backup lose their data on device loss. This must be surfaced clearly in settings.
