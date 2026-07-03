# Phase 3 — Journey Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** User starts a Journey, navigates to a Spot, receives a Task, completes it (including audio recording), adds a Journal Entry, and ends the Journey. The complete solo offline loop.

**Architecture:** Journey Isar model (container) → GpsTracker stream → JourneyProvider (active state) → Task Weaver filters curated library against Spot tags + Persona → Task completion writes to Isar → JournalEntry created at Spot.

**Tech Stack:** Isar 3, Riverpod 2.x, `location` package (GPS), `record` package (audio), bundled JSON task library

## Global Constraints

- Inherits all Phase 1–2 constraints
- `JourneyProvider` holds the single active journey; only one Journey can be active at a time
- `JournalEntry.journeyId` is nullable — entries can exist without a Journey
- Task types: `'sound'`, `'sketch'`, `'tactile'`, `'reflective'` — no other values
- GPS track stored as parallel `trackLats`/`trackLngs` lists (Isar doesn't support nested objects without adapters)
- `assets/tasks/library.json` is bundled in the app; never fetched from network
- Weather snapshot at journey start: fetch from Open-Meteo if online, store as raw JSON string, use `'{}'` if offline

---

## Files

- Create: `lib/features/journey/journey.dart` + `journey.g.dart` (generated)
- Create: `lib/features/journey/journey_provider.dart` + `.g.dart`
- Create: `lib/features/journey/journey_screen.dart`
- Create: `lib/features/journey/gps_tracker.dart`
- Create: `lib/features/tasks/task_template.dart`
- Create: `lib/features/tasks/task.dart` + `task.g.dart` (generated)
- Create: `lib/features/tasks/task_provider.dart` + `.g.dart`
- Create: `lib/features/tasks/task_screen.dart`
- Create: `lib/features/audio/audio_recorder.dart`
- Create: `lib/features/journal/journal_entry.dart` + `journal_entry.g.dart` (generated)
- Create: `lib/features/journal/journal_provider.dart` + `.g.dart`
- Create: `lib/features/journal/journal_screen.dart` (replaces placeholder)
- Create: `assets/tasks/library.json`
- Create: `test/features/tasks/task_provider_test.dart`
- Create: `test/features/journey/journey_provider_test.dart`
- Modify: `lib/main.dart` — register Journey, Task, JournalEntry schemas
- Modify: `lib/app/router.dart` — add `/journey/active` route
- Modify: `pubspec.yaml` — declare assets/tasks/library.json

---

### Task 1: Journey Isar model

- [ ] **Step 1: Implement**

```dart
// lib/features/journey/journey.dart
import 'package:isar/isar.dart';
part 'journey.g.dart';

@collection
class Journey {
  Id id = Isar.autoIncrement;
  late DateTime startTime;
  DateTime? endTime;
  // Parallel lists because Isar 3 can't store List<LatLng> without adapter
  List<double> trackLats = [];
  List<double> trackLngs = [];
  List<String> spotIds = [];
  List<String> taskIds = [];
  String weatherSnapshot = '{}'; // raw JSON from Open-Meteo
  double totalDistanceM = 0.0;

  bool get isActive => endTime == null;

  double get durationHours => endTime == null
      ? DateTime.now().difference(startTime).inMinutes / 60
      : endTime!.difference(startTime).inMinutes / 60;
}
```

- [ ] **Step 2: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Register schema in main.dart**

```dart
// In IsarService.open([...]) call — add JourneySchema:
await IsarService.open([PersonaSchema, SpotSchema, JourneySchema, TaskSchema, JournalEntrySchema]);
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/journey/journey.dart
git commit -m "feat: Journey Isar model"
```

---

### Task 2: GpsTracker

- [ ] **Step 1: Implement**

```dart
// lib/features/journey/gps_tracker.dart
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class GpsTracker {
  static final _location = Location();
  static const _distanceCalc = Distance();

  static Stream<LatLng> get stream async* {
    await _location.requestPermission();
    await _location.changeSettings(accuracy: LocationAccuracy.high, interval: 5000, distanceFilter: 10);
    await for (final data in _location.onLocationChanged) {
      if (data.latitude != null && data.longitude != null) {
        yield LatLng(data.latitude!, data.longitude!);
      }
    }
  }

  static double distanceBetween(List<double> lats, List<double> lngs) {
    if (lats.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < lats.length; i++) {
      total += _distanceCalc(
        LatLng(lats[i - 1], lngs[i - 1]),
        LatLng(lats[i], lngs[i]),
      );
    }
    return total;
  }
}
```

- [ ] **Step 2: Add location permissions**

In `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

In `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ZenVlog needs your location to track your journey.</string>
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/journey/gps_tracker.dart android/ ios/
git commit -m "feat: GpsTracker location stream"
```

---

### Task 3: JourneyProvider

- [ ] **Step 1: Write test**

```dart
// test/features/journey/journey_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/journey/journey.dart';

void main() {
  test('Journey.isActive is true when endTime is null', () {
    final j = Journey()..startTime = DateTime.now();
    expect(j.isActive, isTrue);
  });

  test('Journey.isActive is false after endTime set', () {
    final j = Journey()
      ..startTime = DateTime.now()
      ..endTime = DateTime.now().add(const Duration(hours: 2));
    expect(j.isActive, isFalse);
  });

  test('Journey.durationHours calculates correctly', () {
    final start = DateTime(2026, 1, 1, 9, 0);
    final end = DateTime(2026, 1, 1, 11, 30);
    final j = Journey()..startTime = start..endTime = end;
    expect(j.durationHours, closeTo(2.5, 0.01));
  });
}
```

- [ ] **Step 2: Run tests**

```bash
flutter test test/features/journey/journey_provider_test.dart
```

Expected: PASS (tests Journey model logic, no Isar needed).

- [ ] **Step 3: Implement provider**

```dart
// lib/features/journey/journey_provider.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import 'gps_tracker.dart';
import 'journey.dart';
part 'journey_provider.g.dart';

@riverpod
class JourneyNotifier extends _$JourneyNotifier {
  @override
  Future<Journey?> build() async {
    final isar = IsarService.instance;
    return isar.journeys.filter().endTimeIsNull().findFirst();
  }

  Future<Journey> start(double lat, double lng) async {
    final isar = IsarService.instance;
    final weather = await _fetchWeather(lat, lng);
    final journey = Journey()
      ..startTime = DateTime.now()
      ..weatherSnapshot = weather;
    await isar.writeTxn(() => isar.journeys.put(journey));
    state = AsyncData(journey);
    _startTracking(journey);
    return journey;
  }

  void _startTracking(Journey journey) {
    GpsTracker.stream.listen((point) => addTrackPoint(journey, point.latitude, point.longitude));
  }

  Future<void> addTrackPoint(Journey journey, double lat, double lng) async {
    final isar = IsarService.instance;
    journey.trackLats.add(lat);
    journey.trackLngs.add(lng);
    journey.totalDistanceM = GpsTracker.distanceBetween(journey.trackLats, journey.trackLngs);
    await isar.writeTxn(() => isar.journeys.put(journey));
  }

  Future<Journey> end(Journey journey) async {
    final isar = IsarService.instance;
    journey.endTime = DateTime.now();
    await isar.writeTxn(() => isar.journeys.put(journey));
    state = const AsyncData(null);
    return journey;
  }

  static Future<String> _fetchWeather(double lat, double lng) async {
    try {
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng'
          '&hourly=temperature_2m,precipitation_probability,windspeed_10m'
          '&forecast_days=2';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return res.body;
    } catch (_) {}
    return '{}';
  }
}
```

- [ ] **Step 4: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/
git commit -m "feat: JourneyNotifier with GPS tracking and weather snapshot"
```

---

### Task 4: Task library JSON and model

- [ ] **Step 1: Add asset to pubspec.yaml**

```yaml
flutter:
  assets:
    - assets/tasks/library.json
    - assets/hazards/hazard_zones.geojson
```

- [ ] **Step 2: Create task library JSON (sample — expand to 80 entries)**

```json
// assets/tasks/library.json
[
  {
    "id": "sound_stillness",
    "title": "Sound of Stillness",
    "description": "Record the natural soundscape for 60 seconds. Focus on layers — water, wind, birds, distant sounds.",
    "type": "sound",
    "durationSeconds": 60,
    "requiredOsmTags": ["natural=water"],
    "personaAffinities": [0.2, 0.5, 0.8, 0.9, 0.2]
  },
  {
    "id": "sketch_flow",
    "title": "Sketch the Flow",
    "description": "Find a spot by water and sketch how the stream moves around obstacles.",
    "type": "sketch",
    "durationSeconds": 900,
    "requiredOsmTags": ["natural=water"],
    "personaAffinities": [0.1, 0.7, 0.6, 0.8, 0.3]
  },
  {
    "id": "stone_arrangement",
    "title": "Stone Arrangement",
    "description": "Arrange 5 stones in a pattern that reflects your current state of mind.",
    "type": "tactile",
    "durationSeconds": 600,
    "requiredOsmTags": [],
    "personaAffinities": [0.1, 0.6, 0.9, 0.5, 0.4]
  },
  {
    "id": "light_shadow",
    "title": "Light & Shadow Capture",
    "description": "Photograph the same scene in direct light and shade. Notice what changes.",
    "type": "sketch",
    "durationSeconds": 300,
    "requiredOsmTags": [],
    "personaAffinities": [0.1, 0.8, 0.5, 0.7, 0.2]
  },
  {
    "id": "peak_breath",
    "title": "Peak Breathing",
    "description": "At the highest point you can reach safely, take 10 slow breaths. Count each one.",
    "type": "reflective",
    "durationSeconds": 120,
    "requiredOsmTags": ["natural=peak"],
    "personaAffinities": [0.9, 0.5, 0.7, 0.6, 0.1]
  }
]
```

- [ ] **Step 3: Implement TaskTemplate model**

```dart
// lib/features/tasks/task_template.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class TaskTemplate {
  final String id;
  final String title;
  final String description;
  final String type; // 'sound' | 'sketch' | 'tactile' | 'reflective'
  final int durationSeconds;
  final List<String> requiredOsmTags;
  final List<double> personaAffinities; // [stamina, curiosity, solitude, nature, cultural]

  const TaskTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationSeconds,
    required this.requiredOsmTags,
    required this.personaAffinities,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> j) => TaskTemplate(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        type: j['type'] as String,
        durationSeconds: j['durationSeconds'] as int,
        requiredOsmTags: List<String>.from(j['requiredOsmTags'] as List),
        personaAffinities: List<double>.from((j['personaAffinities'] as List).map((e) => (e as num).toDouble())),
      );

  static Future<List<TaskTemplate>> loadAll() async {
    final data = await rootBundle.loadString('assets/tasks/library.json');
    return (jsonDecode(data) as List).map((e) => TaskTemplate.fromJson(e as Map<String, dynamic>)).toList();
  }
}
```

- [ ] **Step 4: Implement Task Isar model**

```dart
// lib/features/tasks/task.dart
import 'package:isar/isar.dart';
part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  late String templateId;
  late int journeyId;
  late String spotId;
  bool isCompleted = false;
  DateTime? completedAt;
  String? captureFilePath; // audio/photo file path
}
```

- [ ] **Step 5: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Commit**

```bash
git add assets/tasks/ lib/features/tasks/task_template.dart lib/features/tasks/task.dart pubspec.yaml
git commit -m "feat: TaskTemplate library JSON and Task Isar model"
```

---

### Task 5: TaskProvider

- [ ] **Step 1: Write test**

```dart
// test/features/tasks/task_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/tasks/task_provider.dart';
import 'package:app/features/tasks/task_template.dart';
import 'package:app/features/explore/spot.dart';
import 'package:app/features/persona/persona.dart';

void main() {
  test('filterTemplates excludes templates with unmatched required tags', () {
    final templates = [
      const TaskTemplate(
        id: 'water_task', title: '', description: '', type: 'sound',
        durationSeconds: 60, requiredOsmTags: ['natural=water'],
        personaAffinities: [0.5, 0.5, 0.5, 0.9, 0.5],
      ),
      const TaskTemplate(
        id: 'any_task', title: '', description: '', type: 'reflective',
        durationSeconds: 60, requiredOsmTags: [],
        personaAffinities: [0.5, 0.5, 0.5, 0.5, 0.5],
      ),
    ];
    final spot = Spot()..osmTags = ['natural=wood'];
    final persona = Persona.fromSliders(
      stamina: 0.5, curiosity: 0.5, solitudeNeed: 0.5,
      natureAffinity: 0.5, culturalAffinity: 0.5,
    );
    final result = TaskProvider.filterTemplates(templates, spot, persona);
    expect(result.length, 1);
    expect(result.first.id, 'any_task');
  });

  test('filterTemplates ranks by persona affinity dot product', () {
    final templates = [
      const TaskTemplate(
        id: 'low', title: '', description: '', type: 'reflective',
        durationSeconds: 60, requiredOsmTags: [],
        personaAffinities: [0.0, 0.0, 0.0, 0.0, 0.0],
      ),
      const TaskTemplate(
        id: 'high', title: '', description: '', type: 'sound',
        durationSeconds: 60, requiredOsmTags: [],
        personaAffinities: [1.0, 1.0, 1.0, 1.0, 1.0],
      ),
    ];
    final spot = Spot()..osmTags = [];
    final persona = Persona.fromSliders(
      stamina: 0.8, curiosity: 0.8, solitudeNeed: 0.8,
      natureAffinity: 0.8, culturalAffinity: 0.8,
    );
    final result = TaskProvider.filterTemplates(templates, spot, persona);
    expect(result.first.id, 'high');
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/features/tasks/task_provider_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/features/tasks/task_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../explore/spot.dart';
import '../persona/persona.dart';
import 'task.dart';
import 'task_template.dart';
part 'task_provider.g.dart';

class TaskProvider {
  static List<TaskTemplate> filterTemplates(
    List<TaskTemplate> all,
    Spot spot,
    Persona persona,
  ) {
    final eligible = all.where((t) =>
        t.requiredOsmTags.isEmpty ||
        t.requiredOsmTags.any((tag) => spot.osmTags.contains(tag))).toList();

    eligible.sort((a, b) {
      final pv = persona.vector;
      double scoreA = 0, scoreB = 0;
      for (int i = 0; i < 5; i++) {
        scoreA += a.personaAffinities[i] * pv[i];
        scoreB += b.personaAffinities[i] * pv[i];
      }
      return scoreB.compareTo(scoreA);
    });

    return eligible.take(3).toList();
  }
}

@riverpod
Future<List<TaskTemplate>> taskSuggestions(
  TaskSuggestionsRef ref,
  Spot spot,
  Persona persona,
) async {
  final all = await TaskTemplate.loadAll();
  return TaskProvider.filterTemplates(all, spot, persona);
}

@riverpod
class TaskNotifier extends _$TaskNotifier {
  @override
  Future<List<Task>> build(int journeyId) async {
    return IsarService.instance.tasks
        .filter()
        .journeyIdEqualTo(journeyId)
        .findAll();
  }

  Future<Task> assign(String templateId, int journeyId, String spotId) async {
    final task = Task()
      ..templateId = templateId
      ..journeyId = journeyId
      ..spotId = spotId;
    await IsarService.instance.writeTxn(
      () => IsarService.instance.tasks.put(task),
    );
    ref.invalidateSelf();
    return task;
  }

  Future<void> complete(Task task, {String? captureFilePath}) async {
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    task.captureFilePath = captureFilePath;
    await IsarService.instance.writeTxn(
      () => IsarService.instance.tasks.put(task),
    );
    ref.invalidateSelf();
  }
}
```

- [ ] **Step 4: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Run tests**

```bash
flutter test test/features/tasks/task_provider_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/tasks/task_provider.dart test/features/tasks/
git commit -m "feat: TaskProvider filters library by spot tags and persona ranking"
```

---

### Task 6: AudioRecorder

- [ ] **Step 1: Implement**

```dart
// lib/features/audio/audio_recorder.dart
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ZenAudioRecorder {
  final _recorder = AudioRecorder();

  bool get isRecording => _recording;
  bool _recording = false;

  Future<void> start() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    _recording = true;
  }

  Future<String> stop() async {
    final path = await _recorder.stop();
    _recording = false;
    return path ?? '';
  }

  void dispose() => _recorder.dispose();
}
```

- [ ] **Step 2: Add microphone permissions**

In `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

In `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>ZenVlog needs the microphone for Sound of Stillness tasks.</string>
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/audio/ android/ ios/
git commit -m "feat: ZenAudioRecorder wraps record package"
```

---

### Task 7: JournalEntry model and provider

- [ ] **Step 1: Implement JournalEntry model**

```dart
// lib/features/journal/journal_entry.dart
import 'package:isar/isar.dart';
part 'journal_entry.g.dart';

@collection
class JournalEntry {
  Id id = Isar.autoIncrement;
  int? journeyId; // nullable — entries can exist outside a journey
  late String type; // 'text' | 'audio' | 'photo' | 'sketch'
  late String content; // text content OR absolute file path
  double? lat;
  double? lng;
  String? spotName;
  DateTime createdAt = DateTime.now();
}
```

- [ ] **Step 2: Implement JournalProvider**

```dart
// lib/features/journal/journal_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import 'journal_entry.dart';
part 'journal_provider.g.dart';

@riverpod
class JournalNotifier extends _$JournalNotifier {
  @override
  Future<List<JournalEntry>> build() async {
    return IsarService.instance.journalEntrys
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<JournalEntry> add({
    required String type,
    required String content,
    int? journeyId,
    double? lat,
    double? lng,
    String? spotName,
  }) async {
    final entry = JournalEntry()
      ..type = type
      ..content = content
      ..journeyId = journeyId
      ..lat = lat
      ..lng = lng
      ..spotName = spotName;
    await IsarService.instance.writeTxn(
      () => IsarService.instance.journalEntrys.put(entry),
    );
    ref.invalidateSelf();
    return entry;
  }
}
```

- [ ] **Step 3: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/journal/
git commit -m "feat: JournalEntry Isar model and JournalNotifier"
```

---

### Task 8: Journey screen and Task screen

- [ ] **Step 1: Implement Journey screen**

```dart
// lib/features/journey/journey_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/maps/tile_cache_manager.dart';
import '../../app/router.dart';
import '../explore/spot.dart';
import 'journey_provider.dart';
import 'journey.dart';

class JourneyScreen extends ConsumerWidget {
  final Spot destinationSpot;
  const JourneyScreen({super.key, required this.destinationSpot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyNotifierProvider);

    return journeyAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (journey) => _JourneyBody(journey: journey, spot: destinationSpot),
    );
  }
}

class _JourneyBody extends ConsumerWidget {
  final Journey? journey;
  final Spot spot;
  const _JourneyBody({required this.journey, required this.spot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackPoints = journey == null
        ? <LatLng>[]
        : List.generate(journey!.trackLats.length,
            (i) => LatLng(journey!.trackLats[i], journey!.trackLngs[i]));

    return Scaffold(
      appBar: AppBar(
        title: Text(spot.name),
        backgroundColor: const Color(0xFF1A3A2A),
        actions: [
          if (journey != null)
            TextButton(
              onPressed: () async {
                await ref.read(journeyNotifierProvider.notifier).end(journey!);
                if (context.mounted) context.go('/');
              },
              child: const Text('End', style: TextStyle(color: Color(0xFFD4A853))),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(spot.lat, spot.lng),
                initialZoom: 15,
              ),
              children: [
                osmTileLayer(),
                if (trackPoints.length >= 2)
                  PolylineLayer(polylines: [
                    Polyline(points: trackPoints, color: const Color(0xFFD4A853), strokeWidth: 4),
                  ]),
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(spot.lat, spot.lng),
                    child: const Icon(Icons.eco, color: Color(0xFFD4A853), size: 32),
                  ),
                ]),
              ],
            ),
          ),
          _JourneyStats(journey: journey),
        ],
      ),
      floatingActionButton: journey == null
          ? FloatingActionButton.extended(
              onPressed: () => ref
                  .read(journeyNotifierProvider.notifier)
                  .start(spot.lat, spot.lng),
              label: const Text('Start Journey'),
              icon: const Icon(Icons.play_arrow),
            )
          : FloatingActionButton.extended(
              onPressed: () => context.push(kTaskRoute, extra: spot),
              label: const Text('Get Task'),
              icon: const Icon(Icons.assignment),
            ),
    );
  }
}

class _JourneyStats extends StatelessWidget {
  final Journey? journey;
  const _JourneyStats({required this.journey});
  @override
  Widget build(BuildContext context) {
    if (journey == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A3A2A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat('${(journey!.totalDistanceM / 1000).toStringAsFixed(1)} km', 'Distance'),
          _Stat('${journey!.durationHours.toStringAsFixed(1)} h', 'Time'),
          _Stat('${journey!.trackLats.length}', 'Points'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(color: Color(0xFFD4A853), fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(color: Color(0xFFF5F0E8), fontSize: 12)),
        ],
      );
}
```

- [ ] **Step 2: Add routes to router.dart**

```dart
// Add these constants:
const kJourneyActiveRoute = '/journey/active';
const kTaskRoute = '/task';

// Add inside ShellRoute routes (or as top-level routes):
GoRoute(
  path: kJourneyActiveRoute,
  builder: (context, state) => JourneyScreen(destinationSpot: state.extra! as Spot),
),
GoRoute(
  path: kTaskRoute,
  builder: (context, state) => TaskScreen(spot: state.extra! as Spot),
),
```

- [ ] **Step 3: Implement Task screen**

```dart
// lib/features/tasks/task_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_recorder.dart';
import '../explore/spot.dart';
import '../persona/persona_provider.dart';
import 'task_provider.dart';
import 'task_template.dart';

class TaskScreen extends ConsumerStatefulWidget {
  final Spot spot;
  const TaskScreen({super.key, required this.spot});
  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  TaskTemplate? _selected;
  bool _inProgress = false;
  int _elapsed = 0;
  Timer? _timer;
  final _recorder = ZenAudioRecorder();

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaNotifierProvider).value;
    if (persona == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final suggestionsAsync = ref.watch(taskSuggestionsProvider(widget.spot, persona));

    return Scaffold(
      appBar: AppBar(title: const Text('Your Micro-Task')),
      body: suggestionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (templates) => _selected == null
            ? _SuggestionList(templates: templates, onSelect: (t) => setState(() => _selected = t))
            : _TaskInProgress(
                template: _selected!,
                elapsed: _elapsed,
                inProgress: _inProgress,
                recorder: _recorder,
                onStart: _startTask,
                onComplete: _completeTask,
              ),
      ),
    );
  }

  void _startTask() {
    setState(() { _inProgress = true; _elapsed = 0; });
    if (_selected!.type == 'sound') _recorder.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed++);
    });
  }

  Future<void> _completeTask() async {
    _timer?.cancel();
    String? filePath;
    if (_selected!.type == 'sound') filePath = await _recorder.stop();
    // Task assignment and completion handled by JourneyScreen
    if (mounted) Navigator.pop(context, filePath);
  }
}

class _SuggestionList extends StatelessWidget {
  final List<TaskTemplate> templates;
  final void Function(TaskTemplate) onSelect;
  const _SuggestionList({required this.templates, required this.onSelect});

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (_, i) => Card(
          child: ListTile(
            title: Text(templates[i].title, style: const TextStyle(color: Color(0xFF1A3A2A))),
            subtitle: Text(templates[i].description, style: const TextStyle(color: Color(0xFF1A3A2A))),
            trailing: ElevatedButton(
              onPressed: () => onSelect(templates[i]),
              child: const Text('Accept'),
            ),
          ),
        ),
      );
}

class _TaskInProgress extends StatelessWidget {
  final TaskTemplate template;
  final int elapsed;
  final bool inProgress;
  final ZenAudioRecorder recorder;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  const _TaskInProgress({
    required this.template, required this.elapsed, required this.inProgress,
    required this.recorder, required this.onStart, required this.onComplete,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(inProgress ? 'Recording...' : template.title,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('${elapsed}s / ${template.durationSeconds}s',
                style: const TextStyle(color: Color(0xFFD4A853), fontSize: 24)),
            const SizedBox(height: 8),
            Text(template.description, textAlign: TextAlign.center),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: inProgress ? onComplete : onStart,
                child: Text(inProgress ? 'Complete Task' : 'Start Task'),
              ),
            ),
          ],
        ),
      );
}
```

- [ ] **Step 4: Update JournalScreen**

```dart
// lib/features/journal/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_entry.dart';
import 'journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Journal')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('No entries yet'))
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (_, i) => _EntryTile(entry: entries[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTextEntry(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTextEntry(BuildContext context, WidgetRef ref) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _TextEntryDialog(),
    );
    if (text != null && text.isNotEmpty) {
      await ref.read(journalNotifierProvider.notifier).add(type: 'text', content: text);
    }
  }
}

class _EntryTile extends StatelessWidget {
  final JournalEntry entry;
  const _EntryTile({required this.entry});
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(_iconFor(entry.type), color: const Color(0xFFD4A853)),
        title: Text(entry.type == 'text' ? entry.content : entry.type,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(entry.spotName ?? '', style: const TextStyle(fontSize: 12)),
        trailing: Text('${entry.createdAt.hour}:${entry.createdAt.minute.toString().padLeft(2, '0')}'),
      );

  IconData _iconFor(String type) => switch (type) {
        'audio' => Icons.mic,
        'photo' => Icons.photo,
        'sketch' => Icons.draw,
        _ => Icons.notes,
      };
}

class _TextEntryDialog extends StatefulWidget {
  const _TextEntryDialog();
  @override
  State<_TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<_TextEntryDialog> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('New Entry'),
        content: TextField(controller: _ctrl, maxLines: 5, decoration: const InputDecoration(hintText: 'Your reflection...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, _ctrl.text), child: const Text('Save')),
        ],
      );
}
```

- [ ] **Step 5: Run golden-path test**

```bash
flutter run
```

Expected: Tap a spot pin on Explore → Start Journey → GPS track draws on map → Get Task → Accept task → Start (records audio for sound tasks) → Complete → Journal entry created → End Journey → stats visible.

- [ ] **Step 6: Commit**

```bash
git add lib/ assets/
git commit -m "feat: complete solo Journey loop with Tasks and Journal"
```

---

### Task 9: Final checks

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All PASS.

- [ ] **Step 2: Analyze**

```bash
flutter analyze
```

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "chore: Phase 3 Journey complete"
```
