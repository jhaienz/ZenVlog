# Phase 2 — Solo Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** User completes onboarding, gets a Persona, and browses Hidden Spots on an offline-capable map. The full solo discovery loop works end-to-end.

**Architecture:** Isar Persona + Spot models → onboarding sliders write Persona → OSM downloader populates Spots → Serendipity Scraper filters and ranks → flutter_map renders with offline tile cache.

**Tech Stack:** Isar 3, Riverpod 2.x, flutter_map, flutter_map_tile_caching, xml (OSM parsing)

## Global Constraints

- Inherits all Phase 1 constraints
- `Persona.vector` is the canonical 5-element list: `[stamina, curiosity, solitudeNeed, natureAffinity, culturalAffinity]`
- Tag density threshold for "hidden": `tagDensity < 4` (4+ tags = too popular/known)
- Persona scores are dot products in `[0.0, 1.0]`; higher = better match
- OSM download uses Overpass API when online; result is cached to Isar — never re-fetched if Spots exist for that bounding box
- Onboarding is skipped on re-launch if `Persona` exists in Isar

---

## Files

- Create: `lib/features/persona/persona.dart` + `persona.g.dart` (generated)
- Create: `lib/features/persona/persona_provider.dart` + `.g.dart` (generated)
- Create: `lib/features/onboarding/onboarding_screen.dart`
- Create: `lib/features/explore/spot.dart` + `spot.g.dart` (generated)
- Create: `lib/features/explore/serendipity_scraper.dart`
- Create: `lib/features/explore/osm_downloader.dart`
- Create: `lib/features/explore/explore_screen.dart` (replaces placeholder)
- Create: `lib/core/maps/tile_cache_manager.dart`
- Create: `test/features/persona/persona_test.dart`
- Create: `test/features/explore/serendipity_scraper_test.dart`
- Modify: `lib/main.dart` — register Persona + Spot schemas, add onboarding redirect
- Modify: `lib/app/router.dart` — add `/onboarding` route

---

### Task 1: Persona Isar model

- [ ] **Step 1: Write test**

```dart
// test/features/persona/persona_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/persona/persona.dart';

void main() {
  test('Persona.fromSliders sets all fields correctly', () {
    final p = Persona.fromSliders(
      stamina: 0.8,
      curiosity: 0.6,
      solitudeNeed: 0.9,
      natureAffinity: 0.7,
      culturalAffinity: 0.4,
    );
    expect(p.stamina, 0.8);
    expect(p.curiosity, 0.6);
    expect(p.solitudeNeed, 0.9);
    expect(p.natureAffinity, 0.7);
    expect(p.culturalAffinity, 0.4);
  });

  test('Persona.vector returns 5-element list in correct order', () {
    final p = Persona.fromSliders(
      stamina: 0.1, curiosity: 0.2, solitudeNeed: 0.3,
      natureAffinity: 0.4, culturalAffinity: 0.5,
    );
    expect(p.vector, [0.1, 0.2, 0.3, 0.4, 0.5]);
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/features/persona/persona_test.dart
```

Expected: FAIL — `Persona` not defined.

- [ ] **Step 3: Implement**

```dart
// lib/features/persona/persona.dart
import 'package:isar/isar.dart';
part 'persona.g.dart';

@collection
class Persona {
  Id id = Isar.autoIncrement;
  double stamina = 0.5;
  double curiosity = 0.5;
  double solitudeNeed = 0.5;
  double natureAffinity = 0.5;
  double culturalAffinity = 0.5;
  DateTime updatedAt = DateTime.now();
  int completedJourneys = 0;

  Persona();

  factory Persona.fromSliders({
    required double stamina,
    required double curiosity,
    required double solitudeNeed,
    required double natureAffinity,
    required double culturalAffinity,
  }) => Persona()
    ..stamina = stamina
    ..curiosity = curiosity
    ..solitudeNeed = solitudeNeed
    ..natureAffinity = natureAffinity
    ..culturalAffinity = culturalAffinity
    ..updatedAt = DateTime.now();

  List<double> get vector => [stamina, curiosity, solitudeNeed, natureAffinity, culturalAffinity];
}
```

- [ ] **Step 4: Generate Isar code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `persona.g.dart` created.

- [ ] **Step 5: Run tests**

```bash
flutter test test/features/persona/persona_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/persona/ test/features/persona/
git commit -m "feat: Persona Isar model with 5-dimension vector"
```

---

### Task 2: PersonaProvider

- [ ] **Step 1: Implement**

```dart
// lib/features/persona/persona_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import 'persona.dart';
part 'persona_provider.g.dart';

@riverpod
class PersonaNotifier extends _$PersonaNotifier {
  @override
  Future<Persona?> build() async {
    final isar = IsarService.instance;
    return isar.personas.where().findFirst();
  }

  Future<void> save(Persona persona) async {
    final isar = IsarService.instance;
    await isar.writeTxn(() async {
      await isar.personas.clear();
      await isar.personas.put(persona);
    });
    state = AsyncData(persona);
  }

  Future<void> update(Persona updated) async {
    updated.updatedAt = DateTime.now();
    await save(updated);
  }
}
```

- [ ] **Step 2: Generate code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `persona_provider.g.dart` created.

- [ ] **Step 3: Commit**

```bash
git add lib/features/persona/persona_provider.dart
git commit -m "feat: PersonaNotifier Riverpod provider"
```

---

### Task 3: Onboarding screen

- [ ] **Step 1: Implement**

```dart
// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../persona/persona.dart';
import '../persona/persona_provider.dart';
import '../../app/router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  double _stamina = 0.5;
  double _curiosity = 0.5;
  double _solitudeNeed = 0.5;
  double _natureAffinity = 0.5;
  double _culturalAffinity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Design your mindful adventure',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 32),
              _slider('Stamina', _stamina, (v) => setState(() => _stamina = v)),
              _slider('Curiosity', _curiosity, (v) => setState(() => _curiosity = v)),
              _slider('Solitude Need', _solitudeNeed, (v) => setState(() => _solitudeNeed = v)),
              _slider('Nature Affinity', _natureAffinity, (v) => setState(() => _natureAffinity = v)),
              _slider('Cultural Affinity', _culturalAffinity, (v) => setState(() => _culturalAffinity = v)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _start,
                  child: const Text('Start Discovery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Slider(value: value, onChanged: onChanged, activeColor: const Color(0xFFD4A853)),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _start() async {
    final persona = Persona.fromSliders(
      stamina: _stamina,
      curiosity: _curiosity,
      solitudeNeed: _solitudeNeed,
      natureAffinity: _natureAffinity,
      culturalAffinity: _culturalAffinity,
    );
    await ref.read(personaNotifierProvider.notifier).save(persona);
    if (mounted) context.go(kExploreRoute);
  }
}
```

- [ ] **Step 2: Add onboarding route and redirect to router.dart**

```dart
// In router.dart — add after existing imports:
import '../features/onboarding/onboarding_screen.dart';
import '../features/persona/persona_provider.dart';

// Replace GoRouter with:
final router = GoRouter(
  initialLocation: kHomeRoute,
  redirect: (context, state) async {
    // Onboarding redirect is handled by checking Isar directly at startup
    // PersonaNotifier handles this — see main.dart
    return null;
  },
  routes: [
    GoRoute(path: kOnboardingRoute, builder: (_, __) => const OnboardingScreen()),
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
```

- [ ] **Step 3: Update main.dart to redirect to onboarding if no Persona**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/db/isar_service.dart';
import 'core/identity/local_identity.dart';
import 'features/persona/persona.dart';
import 'features/explore/spot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.open([PersonaSchema, SpotSchema]);
  await LocalIdentity.getOrCreate();
  runApp(const ProviderScope(child: _App()));
}

class _App extends ConsumerWidget {
  const _App();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaNotifierProvider);
    return MaterialApp.router(
      title: 'ZenVlog',
      theme: zenvlogTheme,
      routerConfig: GoRouter(
        initialLocation: persona.value == null ? kOnboardingRoute : kHomeRoute,
        routes: router.configuration.routes,
      ),
    );
  }
}
```

Note: Simplify by using a redirect in the GoRouter instead of rebuilding it — adjust if the above causes re-render issues.

- [ ] **Step 4: Run app and verify onboarding → explore flow**

```bash
flutter run
```

Expected: First launch shows onboarding sliders. After tapping "Start Discovery," navigates to Explore tab.

- [ ] **Step 5: Commit**

```bash
git add lib/features/onboarding/ lib/app/router.dart lib/main.dart
git commit -m "feat: onboarding screen writes Persona and navigates to Explore"
```

---

### Task 4: Spot Isar model

- [ ] **Step 1: Implement**

```dart
// lib/features/explore/spot.dart
import 'package:isar/isar.dart';
part 'spot.g.dart';

@collection
class Spot {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String osmId;
  String name = 'Unnamed Place';
  late double lat;
  late double lng;
  List<String> osmTags = [];
  int tagDensity = 0;
  double personaScore = 0.0;
  DateTime discoveredAt = DateTime.now();
}
```

- [ ] **Step 2: Generate code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `spot.g.dart` created.

- [ ] **Step 3: Commit**

```bash
git add lib/features/explore/spot.dart
git commit -m "feat: Spot Isar model"
```

---

### Task 5: Serendipity Scraper

- [ ] **Step 1: Write test**

```dart
// test/features/explore/serendipity_scraper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/explore/serendipity_scraper.dart';
import 'package:app/features/explore/spot.dart';
import 'package:app/features/persona/persona.dart';

void main() {
  test('spots with tagDensity >= 4 are excluded', () {
    final spots = [
      Spot()..osmId = 'a'..tagDensity = 2..osmTags = ['natural=water'],
      Spot()..osmId = 'b'..tagDensity = 5..osmTags = ['natural=water', 'tourism=attraction'],
    ];
    final persona = Persona.fromSliders(
      stamina: 0.5, curiosity: 0.5, solitudeNeed: 0.5,
      natureAffinity: 0.9, culturalAffinity: 0.5,
    );
    final result = SerendipityScraper.filterAndRank(spots, persona);
    expect(result.length, 1);
    expect(result.first.osmId, 'a');
  });

  test('nature-affinity persona ranks natural=water spot higher', () {
    final spots = [
      Spot()..osmId = 'water'..tagDensity = 1..osmTags = ['natural=water'],
      Spot()..osmId = 'peak'..tagDensity = 1..osmTags = ['natural=peak'],
    ];
    final persona = Persona.fromSliders(
      stamina: 0.1, curiosity: 0.5, solitudeNeed: 0.5,
      natureAffinity: 0.9, culturalAffinity: 0.5,
    );
    final result = SerendipityScraper.filterAndRank(spots, persona);
    expect(result.first.osmId, 'water');
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/features/explore/serendipity_scraper_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/features/explore/serendipity_scraper.dart
import '../../core/db/isar_service.dart';
import '../persona/persona.dart';
import 'spot.dart';

class SerendipityScraper {
  static const _tagDensityThreshold = 4;

  static const _tagWeights = {
    'natural=water': [0.0, 0.3, 0.4, 0.9, 0.2],   // [stamina, curiosity, solitude, nature, cultural]
    'natural=wood': [0.2, 0.5, 0.6, 0.8, 0.2],
    'natural=peak': [0.9, 0.7, 0.5, 0.6, 0.1],
    'natural=grassland': [0.3, 0.4, 0.7, 0.7, 0.1],
    'natural=cliff': [0.8, 0.8, 0.4, 0.5, 0.1],
    'natural=cave_entrance': [0.6, 0.9, 0.8, 0.6, 0.3],
  };

  // Used in tests without Isar
  static List<Spot> filterAndRank(List<Spot> candidates, Persona persona) {
    final hidden = candidates.where((s) => s.tagDensity < _tagDensityThreshold).toList();
    for (final spot in hidden) {
      spot.personaScore = _score(spot, persona);
    }
    hidden.sort((a, b) => b.personaScore.compareTo(a.personaScore));
    return hidden;
  }

  static Future<List<Spot>> findHiddenSpots(Persona persona) async {
    final isar = IsarService.instance;
    final candidates = await isar.spots
        .filter()
        .tagDensityLessThan(_tagDensityThreshold)
        .findAll();
    return filterAndRank(candidates, persona);
  }

  static double _score(Spot spot, Persona persona) {
    double score = 0;
    for (final tag in spot.osmTags) {
      final weights = _tagWeights[tag];
      if (weights == null) continue;
      final pv = persona.vector;
      for (int i = 0; i < 5; i++) {
        score += weights[i] * pv[i];
      }
    }
    return score;
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/explore/serendipity_scraper_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/explore/serendipity_scraper.dart test/features/explore/
git commit -m "feat: SerendipityScraper filters low-tag OSM spots and ranks by persona"
```

---

### Task 6: OSM downloader

- [ ] **Step 1: Implement**

```dart
// lib/features/explore/osm_downloader.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/db/isar_service.dart';
import 'spot.dart';

class OsmDownloader {
  // Overpass API — free, no key required
  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Downloads natural features for [bbox] = (south, west, north, east).
  /// No-ops if Spots already exist for this bbox (cached).
  static Future<int> downloadRegion(double south, double west, double north, double east) async {
    final isar = IsarService.instance;
    final existing = await isar.spots.count();
    if (existing > 0) return existing; // ponytail: per-bbox tracking if multi-region needed

    final query = '''
[out:json][timeout:25];
(
  node["natural"~"water|wood|peak|grassland|cliff|cave_entrance"]($south,$west,$north,$east);
  way["natural"~"water|wood|peak|grassland|cliff|cave_entrance"]($south,$west,$north,$east);
);
out center;
''';

    final response = await http.post(
      Uri.parse(_overpassUrl),
      body: {'data': query},
    );
    if (response.statusCode != 200) throw Exception('OSM download failed: ${response.statusCode}');

    final elements = (jsonDecode(response.body)['elements'] as List).cast<Map<String, dynamic>>();
    final spots = elements.map(_toSpot).whereType<Spot>().toList();

    await isar.writeTxn(() => isar.spots.putAll(spots));
    return spots.length;
  }

  static Spot? _toSpot(Map<String, dynamic> el) {
    final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
    final lat = (el['lat'] ?? el['center']?['lat']) as double?;
    final lng = (el['lon'] ?? el['center']?['lon']) as double?;
    if (lat == null || lng == null) return null;

    final osmTags = tags.entries
        .where((e) => ['natural', 'water', 'tourism', 'amenity', 'leisure'].contains(e.key))
        .map((e) => '${e.key}=${e.value}')
        .toList();

    return Spot()
      ..osmId = '${el['type']}_${el['id']}'
      ..name = (tags['name'] as String?) ?? 'Unnamed Place'
      ..lat = lat
      ..lng = lng
      ..osmTags = osmTags
      ..tagDensity = tags.length;
  }
}
```

- [ ] **Step 2: Add `http` to pubspec.yaml under dependencies**

```yaml
  http: ^1.2.1
```

```bash
flutter pub get
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/explore/osm_downloader.dart pubspec.yaml pubspec.lock
git commit -m "feat: OSM Overpass downloader populates Spot collection"
```

---

### Task 7: Tile cache manager + Explore screen

- [ ] **Step 1: Configure tile caching**

```dart
// lib/core/maps/tile_cache_manager.dart
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

const _osmStore = 'osm_standard';
const _topoStore = 'opentopomap';

Future<void> initTileCache() async {
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore(_osmStore).manage.create();
  await const FMTCStore(_topoStore).manage.create();
}

TileLayer osmTileLayer() => FMTCStore(_osmStore).getTileProvider().toTileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.zenvlog.app',
    );

TileLayer topoTileLayer() => FMTCStore(_topoStore).getTileProvider().toTileLayer(
      urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.zenvlog.app',
    );
```

- [ ] **Step 2: Call `initTileCache()` in main.dart before runApp**

```dart
// In main() after IsarService.open():
await initTileCache();
```

- [ ] **Step 3: Implement Explore screen**

```dart
// lib/features/explore/explore_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../persona/persona_provider.dart';
import '../../core/maps/tile_cache_manager.dart';
import 'serendipity_scraper.dart';
import 'spot.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  List<Spot> _spots = [];

  @override
  void initState() {
    super.initState();
    _loadSpots();
  }

  Future<void> _loadSpots() async {
    final persona = await ref.read(personaNotifierProvider.future);
    if (persona == null) return;
    final spots = await SerendipityScraper.findHiddenSpots(persona);
    if (mounted) setState(() => _spots = spots.take(20).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(initialCenter: LatLng(35.6762, 139.6503), initialZoom: 13),
        children: [
          osmTileLayer(),
          MarkerLayer(
            markers: _spots.map((s) => Marker(
              point: LatLng(s.lat, s.lng),
              child: const Icon(Icons.eco, color: Color(0xFFD4A853), size: 28),
            )).toList(),
          ),
        ],
      ),
      bottomSheet: _spots.isEmpty
          ? null
          : SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _spots.length,
                itemBuilder: (_, i) => _SpotCard(spot: _spots[i]),
              ),
            ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  final Spot spot;
  const _SpotCard({required this.spot});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(spot.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3A2A))),
            Text('${spot.osmTags.take(2).join(' · ')}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF1A3A2A))),
            Text('Score: ${spot.personaScore.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF1A3A2A))),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run and test golden path**

```bash
flutter run
```

Expected: Complete onboarding → Explore tab shows map with amber spot pins and a horizontal card list below.

- [ ] **Step 5: Test offline: enable airplane mode, relaunch**

Expected: Map shows cached tiles (if previously browsed), spot pins visible (from Isar).

- [ ] **Step 6: Commit**

```bash
git add lib/features/explore/ lib/core/maps/ lib/main.dart
git commit -m "feat: offline map with Serendipity Scraper spot pins"
```

---

### Task 8: Final checks

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All PASS.

- [ ] **Step 2: Run analysis**

```bash
flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "chore: Phase 2 Solo Core complete"
```
