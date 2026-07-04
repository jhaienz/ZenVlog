# Release Build

## Signing (once)

```bash
keytool -genkey -v -keystore ~/zenvlog-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias zenvlog
```

Create `android/key.properties` (gitignored):

```properties
storeFile=/home/YOU/zenvlog-release.jks
storePassword=...
keyAlias=zenvlog
keyPassword=...
```

Without `key.properties` release builds fall back to debug keys (fine for testing, not for Play).

## Icon & splash

Generated from `assets/branding/` via:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Re-run after changing the branding PNGs.

## Build

```bash
# Dev release (no Supabase needed):
flutter build apk --release

# Production (after docs/SUPABASE_SETUP.md):
flutter build apk --release --dart-define=ENV=prod
```

The fat APK is ~185MB (MediaPipe LLM runtime ships native libs for every
ABI). For distribution use one of:

```bash
flutter build apk --release --split-per-abi   # ~60-70MB per APK
flutter build appbundle --release             # Play serves per-device
```
