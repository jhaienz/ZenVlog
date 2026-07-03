# Phase 1 — Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a navigable Flutter shell with theming, Isar database, and local UUID identity — the skeleton every other phase plugs into.

**Architecture:** `flutter create` → add all deps → theme → Isar singleton → UUID identity → 4-tab shell router → wire main.dart.

**Tech Stack:** Flutter 3.22+, go_router, Isar 3, flutter_secure_storage, uuid, Riverpod 2.x

## Global Constraints

- Package name: `com.zenvlog.app`
- Min iOS: 16.0, Min Android: API 26
- Primary color: `Color(0xFF1A3A2A)`, card/cream: `Color(0xFFF5F0E8)`, amber accent: `Color(0xFFD4A853)`
- All providers use `@riverpod` code generation
- No Supabase client initialized in this phase or any phase before Phase 6
- Run `dart run build_runner build --delete-conflicting-outputs` after any model/provider change

---

## Files

- Create: `pubspec.yaml` (replace generated)
- Create: `lib/main.dart`
- Create: `lib/app/theme.dart`
- Create: `lib/app/router.dart`
- Create: `lib/core/db/isar_service.dart`
- Create: `lib/core/identity/local_identity.dart`
- Create: `test/core/identity/local_identity_test.dart`

---

### Task 1: Create Flutter project

- [ ] **Step 1: Create project**

```bash
flutter create --org com.zenvlog --project-name app .
```

Expected: Flutter project created in current directory.

- [ ] **Step 2: Verify it runs**

```bash
flutter run
```

Expected: Default counter app launches on connected device/emulator.

- [ ] **Step 3: Commit**

```bash
git init
git add .
git commit -m "feat: flutter create com.zenvlog.app"
```

---

### Task 2: Add all dependencies

- [ ] **Step 1: Replace pubspec.yaml**

```yaml
name: app
description: ZenVlog — The Silent Synergy Journal
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  # State & Navigation
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.7
  # Local storage
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3
  flutter_secure_storage: ^9.2.2
  uuid: ^4.4.0
  # Maps
  flutter_map: ^7.0.2
  flutter_map_tile_caching: ^9.1.0
  # Bluetooth
  flutter_blue_plus: ^1.32.12
  # Audio
  record: ^5.1.2
  # ML
  tflite_flutter: ^0.10.4
  # Community (initialized Phase 6 only)
  supabase_flutter: ^2.5.6
  # Sensors
  sensors_plus: ^4.0.2
  # Location
  location: ^6.0.2
  # Code gen helpers
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  isar_generator: ^3.1.0+1
```

- [ ] **Step 2: Install**

```bash
flutter pub get
```

Expected: All packages resolved, no version conflicts.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add all project dependencies"
```

---

### Task 3: Theme

- [ ] **Step 1: Write test**

```dart
// test/app/theme_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/theme.dart';
import 'package:flutter/material.dart';

void main() {
  test('primary color is forest green', () {
    expect(zenvlogTheme.colorScheme.primary, const Color(0xFF1A3A2A));
  });

  test('card color is cream', () {
    expect(zenvlogTheme.cardColor, const Color(0xFFF5F0E8));
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/app/theme_test.dart
```

Expected: FAIL — `zenvlogTheme` not defined.

- [ ] **Step 3: Implement**

```dart
// lib/app/theme.dart
import 'package:flutter/material.dart';

const _green = Color(0xFF1A3A2A);
const _cream = Color(0xFFF5F0E8);
const _amber = Color(0xFFD4A853);

final zenvlogTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: _green,
    secondary: _amber,
    surface: const Color(0xFF243D30),
    onPrimary: _cream,
    onSecondary: _green,
    onSurface: _cream,
  ),
  scaffoldBackgroundColor: _green,
  cardColor: _cream,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: _cream, fontWeight: FontWeight.w700, fontSize: 28),
    headlineMedium: TextStyle(color: _cream, fontWeight: FontWeight.w600, fontSize: 22),
    bodyLarge: TextStyle(color: _cream, fontSize: 16),
    bodyMedium: TextStyle(color: _cream, fontSize: 14),
    labelLarge: TextStyle(color: _cream, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _amber,
      foregroundColor: _green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _green,
    selectedItemColor: _amber,
    unselectedItemColor: _cream,
    type: BottomNavigationBarType.fixed,
  ),
);
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/app/theme_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/app/theme.dart test/app/theme_test.dart
git commit -m "feat: add ZenVlog design system theme"
```

---

### Task 4: Isar service

- [ ] **Step 1: Write test**

```dart
// test/core/db/isar_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/db/isar_service.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('IsarService.open returns Isar instance and subsequent calls return same instance', () async {
    await Isar.initializeIsarCore(download: false);
    final db1 = await IsarService.open([]);
    final db2 = await IsarService.open([]);
    expect(db1, same(db2));
    await IsarService.close();
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/core/db/isar_service_test.dart
```

Expected: FAIL — `IsarService` not defined.

- [ ] **Step 3: Implement**

```dart
// lib/core/db/isar_service.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _instance;

  static Future<Isar> open(List<CollectionSchema<dynamic>> schemas) async {
    if (_instance != null && _instance!.isOpen) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(schemas, directory: dir.path);
    return _instance!;
  }

  static Isar get instance {
    assert(_instance != null && _instance!.isOpen, 'Call IsarService.open() first');
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/db/isar_service_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/db/isar_service.dart test/core/db/isar_service_test.dart
git commit -m "feat: add IsarService singleton"
```

---

### Task 5: Local identity

- [ ] **Step 1: Write test**

```dart
// test/core/identity/local_identity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/core/identity/local_identity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('getOrCreate returns non-empty UUID', () async {
    final id = await LocalIdentity.getOrCreate();
    expect(id, isNotEmpty);
    expect(id.length, 36); // UUID v4 length
  });

  test('getOrCreate returns same UUID on repeated calls', () async {
    final id1 = await LocalIdentity.getOrCreate();
    final id2 = await LocalIdentity.getOrCreate();
    expect(id1, equals(id2));
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/core/identity/local_identity_test.dart
```

Expected: FAIL — `LocalIdentity` not defined.

- [ ] **Step 3: Implement**

```dart
// lib/core/identity/local_identity.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class LocalIdentity {
  static const _key = 'zenvlog_local_uuid';
  static const _storage = FlutterSecureStorage();

  static Future<String> getOrCreate() async {
    final existing = await _storage.read(key: _key);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    await _storage.write(key: _key, value: id);
    return id;
  }

  static Future<String> get current async => getOrCreate();
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/core/identity/local_identity_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/identity/local_identity.dart test/core/identity/local_identity_test.dart
git commit -m "feat: add LocalIdentity UUID generation"
```

---

### Task 6: Router and navigation shell

- [ ] **Step 1: Create placeholder screens**

```dart
// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Home'));
}

// lib/features/explore/explore_screen.dart
import 'package:flutter/material.dart';
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Explore'));
}

// lib/features/journal/journal_screen.dart
import 'package:flutter/material.dart';
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Journal'));
}

// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Profile'));
}
```

- [ ] **Step 2: Implement router**

```dart
// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/profile/profile_screen.dart';

const kHomeRoute = '/';
const kExploreRoute = '/explore';
const kJournalRoute = '/journal';
const kProfileRoute = '/profile';
const kOnboardingRoute = '/onboarding';
const kJourneyActiveRoute = '/journey/active';
const kGroupRoute = '/group';
const kCommunityRoute = '/community';

final router = GoRouter(
  initialLocation: kHomeRoute,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _NavShell(child: child),
      routes: [
        GoRoute(path: kHomeRoute, builder: (_, __) => const HomeScreen()),
        GoRoute(path: kExploreRoute, builder: (_, __) => const ExploreScreen()),
        GoRoute(path: kJournalRoute, builder: (_, __) => const JournalScreen()),
        GoRoute(path: kProfileRoute, builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

class _NavShell extends StatelessWidget {
  final Widget child;
  const _NavShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexFor(location),
        onTap: (i) => [kHomeRoute, kExploreRoute, kJournalRoute, kProfileRoute][i]
            .let((r) => context.go(r)),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _indexFor(String location) {
    if (location.startsWith(kExploreRoute)) return 1;
    if (location.startsWith(kJournalRoute)) return 2;
    if (location.startsWith(kProfileRoute)) return 3;
    return 0;
  }
}

extension on String {
  T let<T>(T Function(String) fn) => fn(this);
}
```

- [ ] **Step 3: Wire main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/db/isar_service.dart';
import 'core/identity/local_identity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.open([]); // schemas added per phase
  await LocalIdentity.getOrCreate();
  runApp(const ProviderScope(child: _App()));
}

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'ZenVlog',
        theme: zenvlogTheme,
        routerConfig: router,
      );
}
```

- [ ] **Step 4: Run app and verify all 4 tabs navigate**

```bash
flutter run
```

Expected: App launches with green background, 4 tabs in bottom nav, each tab shows correct placeholder text.

- [ ] **Step 5: Commit**

```bash
git add lib/
git commit -m "feat: navigation shell with 4-tab go_router layout"
```

---

### Task 7: Smoke test

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All tests PASS.

- [ ] **Step 2: Run analysis**

```bash
flutter analyze
```

Expected: No errors (warnings acceptable).

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "chore: Phase 1 foundation complete"
```
