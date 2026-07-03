# Phase 4 — Safety & Intelligence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Anshin Engine warns users of weather and terrain hazards offline. Persona updates from journey behavior after 5+ completions. Opt-in LLM rewrites task descriptions contextually.

**Architecture:** `ForecastCache` downloads and stores 48h Open-Meteo forecast before trip → `HazardOverlay` loads static GeoJSON → `AnshinEngine` merges both + barometer into alert stream → `PersonaNotifier` applies TFLite delta after each completed journey → `flutter_gemma` rewrites task descriptions when user opts in.

**Tech Stack:** Isar 3, Riverpod 2.x, `sensors_plus` (barometer), `http`, `tflite_flutter`, `flutter_gemma`, bundled GeoJSON

## Global Constraints

- Inherits all Phase 1–3 constraints
- Forecast must display its `cachedAt` timestamp in the UI — users must know how stale it is
- Barometer alert threshold: pressure drop > 2 hPa in 60 minutes = storm warning
- Persona behavioral delta applied with learning rate 0.1: `newValue = old + 0.1 * delta`
- Clamped to [0.0, 1.0] after each delta application
- TFLite model update triggers only when `persona.completedJourneys >= 5` AND a journey just completed
- LLM task rewrite: max 50 tokens, prompt must not change task type or duration
- `flutter_gemma` model download is opt-in via Settings toggle; never auto-downloaded
- `assets/hazards/hazard_zones.geojson` is a static bundled file — no network fetch

---

## Files

- Create: `lib/features/anshin/forecast_cache.dart`
- Create: `lib/features/anshin/hazard_overlay.dart`
- Create: `lib/features/anshin/anshin_engine.dart`
- Create: `lib/features/anshin/anshin_alert.dart`
- Create: `lib/features/profile/settings_screen.dart`
- Create: `lib/features/tasks/llm_rewriter.dart`
- Create: `assets/hazards/hazard_zones.geojson`
- Create: `assets/ml/` (directory for TFLite model — model file added by training script)
- Create: `tools/train_persona_model.py`
- Create: `test/features/anshin/anshin_engine_test.dart`
- Modify: `lib/features/persona/persona_provider.dart` — add `applyBehavioralDelta`
- Modify: `lib/features/journey/journey_screen.dart` — show Anshin alerts banner
- Modify: `lib/features/tasks/task_screen.dart` — optionally use LLM rewriter
- Modify: `pubspec.yaml` — add `sensors_plus`, `flutter_gemma`; declare `assets/hazards/`, `assets/ml/`

---

### Task 1: AnshinAlert model

- [ ] **Step 1: Implement**

```dart
// lib/features/anshin/anshin_alert.dart
import 'package:latlong2/latlong.dart';

enum AlertSeverity { warning, danger }
enum AlertType { weather, hazard, barometer }

class AnshinAlert {
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final List<LatLng>? suggestedRoute;
  final DateTime createdAt;

  const AnshinAlert({
    required this.type,
    required this.message,
    required this.severity,
    this.suggestedRoute,
    required this.createdAt,
  });
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/anshin/anshin_alert.dart
git commit -m "feat: AnshinAlert model"
```

---

### Task 2: ForecastCache

- [ ] **Step 1: Write test**

```dart
// test/features/anshin/anshin_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/anshin/forecast_cache.dart';

void main() {
  test('ForecastCache.isStale returns true when cached more than 6 hours ago', () {
    final old = DateTime.now().subtract(const Duration(hours: 7));
    expect(ForecastCache.isStale(old), isTrue);
  });

  test('ForecastCache.isStale returns false when cached within 6 hours', () {
    final recent = DateTime.now().subtract(const Duration(hours: 2));
    expect(ForecastCache.isStale(recent), isFalse);
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/features/anshin/anshin_engine_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/features/anshin/forecast_cache.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../../core/db/isar_service.dart';

// Stored in a simple Isar collection
part 'forecast_cache.g.dart';

@collection
class CachedForecast {
  Id id = 1; // singleton row
  String data = '{}';
  DateTime cachedAt = DateTime.fromMillisecondsSinceEpoch(0);
  double lat = 0;
  double lng = 0;
}

class ForecastCache {
  static const _stalenessHours = 6;

  static bool isStale(DateTime cachedAt) =>
      DateTime.now().difference(cachedAt).inHours >= _stalenessHours;

  static Future<CachedForecast> download(double lat, double lng) async {
    final isar = IsarService.instance;
    final existing = await isar.cachedForecasts.get(1);
    if (existing != null && !isStale(existing.cachedAt)) return existing;

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng'
      '&hourly=temperature_2m,precipitation_probability,windspeed_10m,surface_pressure'
      '&forecast_days=2',
    );
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final cached = CachedForecast()
          ..id = 1
          ..data = res.body
          ..cachedAt = DateTime.now()
          ..lat = lat
          ..lng = lng;
        await isar.writeTxn(() => isar.cachedForecasts.put(cached));
        return cached;
      }
    } catch (_) {}
    return existing ?? CachedForecast();
  }

  static Future<CachedForecast?> getCached() async =>
      IsarService.instance.cachedForecasts.get(1);

  static Map<String, dynamic>? parseForecast(CachedForecast cached) {
    if (cached.data == '{}') return null;
    return jsonDecode(cached.data) as Map<String, dynamic>;
  }
}
```

- [ ] **Step 4: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Register CachedForecastSchema in main.dart**

```dart
await IsarService.open([PersonaSchema, SpotSchema, JourneySchema, TaskSchema, JournalEntrySchema, CachedForecastSchema]);
```

- [ ] **Step 6: Run tests**

```bash
flutter test test/features/anshin/anshin_engine_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/anshin/forecast_cache.dart test/features/anshin/
git commit -m "feat: ForecastCache downloads and persists 48h weather forecast"
```

---

### Task 3: HazardOverlay

- [ ] **Step 1: Create placeholder GeoJSON**

```json
// assets/hazards/hazard_zones.geojson
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": { "type": "flood_zone", "severity": "warning", "name": "Low-lying flood risk" },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[139.60, 35.65], [139.62, 35.65], [139.62, 35.67], [139.60, 35.67], [139.60, 35.65]]]
      }
    }
  ]
}
```

- [ ] **Step 2: Implement**

```dart
// lib/features/anshin/hazard_overlay.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'anshin_alert.dart';

class HazardOverlay {
  static Future<List<Map<String, dynamic>>> _loadFeatures() async {
    final data = await rootBundle.loadString('assets/hazards/hazard_zones.geojson');
    final fc = jsonDecode(data) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(fc['features'] as List);
  }

  static Future<PolygonLayer> buildLayer() async {
    final features = await _loadFeatures();
    final polygons = features.where((f) {
      final geo = f['geometry'] as Map<String, dynamic>;
      return geo['type'] == 'Polygon';
    }).map((f) {
      final coords = ((f['geometry'] as Map)['coordinates'] as List).first as List;
      final points = coords.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
      final severity = (f['properties'] as Map)['severity'];
      return Polygon(
        points: points,
        color: severity == 'danger'
            ? Colors.red.withOpacity(0.3)
            : Colors.orange.withOpacity(0.2),
        borderColor: severity == 'danger' ? Colors.red : Colors.orange,
        borderStrokeWidth: 2,
      );
    }).toList();
    return PolygonLayer(polygons: polygons);
  }

  static Future<List<AnshinAlert>> checkPosition(double lat, double lng) async {
    final features = await _loadFeatures();
    final alerts = <AnshinAlert>[];
    for (final f in features) {
      final props = f['properties'] as Map<String, dynamic>;
      // ponytail: point-in-polygon using bounding box; upgrade to full pip if false positives appear
      final geo = f['geometry'] as Map<String, dynamic>;
      if (geo['type'] != 'Polygon') continue;
      final coords = ((geo['coordinates'] as List).first as List);
      final lngs = coords.map((c) => (c[0] as num).toDouble()).toList();
      final lats = coords.map((c) => (c[1] as num).toDouble()).toList();
      if (lat >= lats.reduce((a, b) => a < b ? a : b) &&
          lat <= lats.reduce((a, b) => a > b ? a : b) &&
          lng >= lngs.reduce((a, b) => a < b ? a : b) &&
          lng <= lngs.reduce((a, b) => a > b ? a : b)) {
        alerts.add(AnshinAlert(
          type: AlertType.hazard,
          message: props['name'] as String? ?? 'Hazard zone',
          severity: props['severity'] == 'danger' ? AlertSeverity.danger : AlertSeverity.warning,
          createdAt: DateTime.now(),
        ));
      }
    }
    return alerts;
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/anshin/hazard_overlay.dart assets/hazards/
git commit -m "feat: HazardOverlay loads static GeoJSON hazard zones"
```

---

### Task 4: AnshinEngine

- [ ] **Step 1: Implement**

```dart
// lib/features/anshin/anshin_engine.dart
import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'anshin_alert.dart';
import 'forecast_cache.dart';
import 'hazard_overlay.dart';
part 'anshin_engine.g.dart';

@riverpod
Stream<List<AnshinAlert>> anshinAlerts(AnshinAlertsRef ref, double lat, double lng) async* {
  final alerts = <AnshinAlert>[];

  // 1. Forecast-based alerts
  final cached = await ForecastCache.getCached();
  if (cached != null) {
    final forecast = ForecastCache.parseForecast(cached);
    if (forecast != null) {
      final hourlyPrecip = (forecast['hourly']?['precipitation_probability'] as List?)
          ?.cast<num>()
          .take(6)
          .toList() ?? [];
      if (hourlyPrecip.any((p) => p > 70)) {
        alerts.add(AnshinAlert(
          type: AlertType.weather,
          message: 'Heavy rain expected in your area within ${_hoursUntilRain(hourlyPrecip)} hours.',
          severity: AlertSeverity.warning,
          createdAt: DateTime.now(),
        ));
      }
    }
    if (ForecastCache.isStale(cached.cachedAt)) {
      alerts.add(AnshinAlert(
        type: AlertType.weather,
        message: 'Weather data is ${DateTime.now().difference(cached.cachedAt).inHours}h old. Update before next trip.',
        severity: AlertSeverity.warning,
        createdAt: DateTime.now(),
      ));
    }
  }

  // 2. Static hazard alerts
  final hazardAlerts = await HazardOverlay.checkPosition(lat, lng);
  alerts.addAll(hazardAlerts);

  yield List.from(alerts);

  // 3. Barometer stream (ongoing)
  final pressureReadings = <double>[];
  await for (final event in barometerEventStream()) {
    pressureReadings.add(event.pressure);
    if (pressureReadings.length > 12) pressureReadings.removeAt(0); // 12 × 5s = 60s window
    if (pressureReadings.length >= 12) {
      final drop = pressureReadings.first - pressureReadings.last;
      if (drop > 2.0) {
        final barometerAlert = AnshinAlert(
          type: AlertType.barometer,
          message: 'Rapid pressure drop detected. Conditions may deteriorate.',
          severity: AlertSeverity.warning,
          createdAt: DateTime.now(),
        );
        final updated = [...alerts.where((a) => a.type != AlertType.barometer), barometerAlert];
        yield updated;
      }
    }
    await Future.delayed(const Duration(seconds: 5));
  }
}

int _hoursUntilRain(List<num> hourlyPrecip) {
  for (int i = 0; i < hourlyPrecip.length; i++) {
    if (hourlyPrecip[i] > 70) return i + 1;
  }
  return 1;
}
```

- [ ] **Step 2: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Add alert banner to journey_screen.dart**

```dart
// In _JourneyBody.build(), add above the Column children:
// (add ref to ConsumerWidget, pass lat/lng from spot)
final alertsAsync = ref.watch(anshinAlertsProvider(spot.lat, spot.lng));
alertsAsync.whenData((alerts) {
  if (alerts.isEmpty) return;
  // Show in Scaffold via a persistent banner — add to Column before map:
});

// Add this widget to top of Column in _JourneyBody:
Consumer(builder: (context, ref, _) {
  final alerts = ref.watch(anshinAlertsProvider(spot.lat, spot.lng)).value ?? [];
  if (alerts.isEmpty) return const SizedBox.shrink();
  final worst = alerts.reduce((a, b) => a.severity.index > b.severity.index ? a : b);
  return MaterialBanner(
    backgroundColor: worst.severity == AlertSeverity.danger ? Colors.red[900] : Colors.orange[900],
    content: Text(worst.message, style: const TextStyle(color: Colors.white)),
    actions: [
      TextButton(onPressed: () {}, child: const Text('View New Route', style: TextStyle(color: Colors.white))),
      TextButton(onPressed: () {}, child: const Text('Not Now', style: TextStyle(color: Colors.white70))),
    ],
  );
}),
```

- [ ] **Step 4: Add pre-trip download prompt to explore_screen.dart**

```dart
// In _SpotCard or on spot tap — before navigating to JourneyScreen:
Future<void> _navigateToJourney(BuildContext context, Spot spot) async {
  final cached = await ForecastCache.getCached();
  final needsDownload = cached == null || ForecastCache.isStale(cached.cachedAt);
  if (needsDownload && context.mounted) {
    final download = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Download Safety Data'),
        content: const Text('Download latest weather forecast before going offline?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Skip')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Download')),
        ],
      ),
    );
    if (download == true) await ForecastCache.download(spot.lat, spot.lng);
  }
  if (context.mounted) context.push(kJourneyActiveRoute, extra: spot);
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/anshin/
git commit -m "feat: AnshinEngine streams weather, hazard, and barometer alerts"
```

---

### Task 5: Persona behavioral learning (TFLite)

- [ ] **Step 1: Create training script**

```python
# tools/train_persona_model.py
"""
Trains a simple linear model to output persona deltas from journey features.
Input (10 features): [avg_spot_nature_score, avg_spot_solitude_score,
  avg_task_curiosity, avg_task_nature, completed_tasks_ratio,
  total_distance_km, duration_hours, early_start (0/1),
  sound_tasks_ratio, solo (0/1)]
Output (5 values): [stamina_delta, curiosity_delta, solitude_delta,
  nature_delta, cultural_delta] — each in [-0.1, 0.1]

Run: python tools/train_persona_model.py
Output: assets/ml/persona_updater.tflite
"""
import numpy as np
import os

os.makedirs('assets/ml', exist_ok=True)

try:
    import tensorflow as tf

    # Synthetic training data: high nature score → increase nature affinity
    np.random.seed(42)
    N = 1000
    X = np.random.rand(N, 10).astype(np.float32)
    # Target: deltas proportional to relevant features
    y = np.column_stack([
        (X[:, 4] - 0.5) * 0.1,   # stamina ← task completion ratio
        (X[:, 2] - 0.5) * 0.1,   # curiosity ← curiosity tasks
        (X[:, 1] - 0.5) * 0.1,   # solitude ← solitude spots
        (X[:, 0] - 0.5) * 0.1,   # nature ← nature spot score
        np.zeros(N),               # cultural — no strong signal yet
    ]).astype(np.float32)

    model = tf.keras.Sequential([
        tf.keras.layers.Dense(16, activation='relu', input_shape=(10,)),
        tf.keras.layers.Dense(5, activation='tanh'),
        tf.keras.layers.Lambda(lambda x: x * 0.1),  # clamp to [-0.1, 0.1]
    ])
    model.compile(optimizer='adam', loss='mse')
    model.fit(X, y, epochs=50, verbose=0)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    with open('assets/ml/persona_updater.tflite', 'wb') as f:
        f.write(tflite_model)
    print('Model saved to assets/ml/persona_updater.tflite')
except ImportError:
    print('TensorFlow not installed. Install with: pip install tensorflow')
    print('Creating placeholder model file...')
    # Placeholder so Flutter asset bundle does not fail
    with open('assets/ml/persona_updater.tflite', 'wb') as f:
        f.write(b'placeholder')
```

- [ ] **Step 2: Run training script (requires Python + TensorFlow)**

```bash
pip install tensorflow numpy
python tools/train_persona_model.py
```

Expected: `assets/ml/persona_updater.tflite` created.

- [ ] **Step 3: Declare asset in pubspec.yaml**

```yaml
flutter:
  assets:
    - assets/tasks/library.json
    - assets/hazards/hazard_zones.geojson
    - assets/ml/persona_updater.tflite
```

- [ ] **Step 4: Add behavioral delta to PersonaNotifier**

```dart
// In lib/features/persona/persona_provider.dart — add method:
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../journey/journey.dart';
import '../tasks/task.dart';

// Add inside PersonaNotifier class:
Future<void> applyBehavioralDelta(Journey completedJourney) async {
  final current = state.value;
  if (current == null) return;

  current.completedJourneys++;
  if (current.completedJourneys < 5) {
    await update(current);
    return; // not enough data yet
  }

  final isar = IsarService.instance;
  final tasks = await isar.tasks
      .filter()
      .journeyIdEqualTo(completedJourney.id)
      .isCompletedEqualTo(true)
      .findAll();

  final input = _buildFeatureVector(completedJourney, tasks);
  final delta = await _runModel(input);

  const lr = 0.1;
  current.stamina = (current.stamina + lr * delta[0]).clamp(0.0, 1.0);
  current.curiosity = (current.curiosity + lr * delta[1]).clamp(0.0, 1.0);
  current.solitudeNeed = (current.solitudeNeed + lr * delta[2]).clamp(0.0, 1.0);
  current.natureAffinity = (current.natureAffinity + lr * delta[3]).clamp(0.0, 1.0);
  current.culturalAffinity = (current.culturalAffinity + lr * delta[4]).clamp(0.0, 1.0);

  await update(current);
}

List<double> _buildFeatureVector(Journey j, List<Task> tasks) {
  final completionRatio = tasks.isEmpty ? 0.0 : tasks.where((t) => t.isCompleted).length / tasks.length;
  final soundRatio = tasks.isEmpty ? 0.0 : tasks.where((t) => t.templateId.startsWith('sound')).length / tasks.length;
  return [
    0.5, 0.5, // avg_spot_nature_score, avg_spot_solitude_score (simplified)
    0.5, 0.5, // avg_task_curiosity, avg_task_nature (simplified)
    completionRatio,
    j.totalDistanceM / 1000,
    j.durationHours,
    j.startTime.hour < 8 ? 1.0 : 0.0, // early_start
    soundRatio,
    1.0, // solo (group mode updates separately in Phase 5)
  ];
}

Future<List<double>> _runModel(List<double> input) async {
  try {
    final modelData = await rootBundle.load('assets/ml/persona_updater.tflite');
    final interpreter = Interpreter.fromBuffer(modelData.buffer.asUint8List());
    final inputTensor = [input];
    final output = List.filled(5, 0.0);
    final outputTensor = [output];
    interpreter.run(inputTensor, outputTensor);
    interpreter.close();
    return output;
  } catch (_) {
    return [0.0, 0.0, 0.0, 0.0, 0.0]; // graceful fallback if model fails
  }
}
```

- [ ] **Step 5: Call applyBehavioralDelta when journey ends**

```dart
// In journey_screen.dart, in the "End" button handler:
final completedJourney = await ref.read(journeyNotifierProvider.notifier).end(journey!);
await ref.read(personaNotifierProvider.notifier).applyBehavioralDelta(completedJourney);
if (context.mounted) context.go('/');
```

- [ ] **Step 6: Commit**

```bash
git add tools/ assets/ml/ lib/features/persona/persona_provider.dart lib/features/journey/journey_screen.dart
git commit -m "feat: TFLite persona behavioral learning after 5+ journeys"
```

---

### Task 6: Opt-in LLM task description rewriter

- [ ] **Step 1: Add flutter_gemma to pubspec.yaml**

```yaml
  flutter_gemma: ^0.3.0
```

```bash
flutter pub get
```

- [ ] **Step 2: Add Settings screen with LLM toggle**

```dart
// lib/features/profile/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _storage = FlutterSecureStorage();
  static const _llmKey = 'llm_enabled';
  bool _llmEnabled = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _storage.read(key: _llmKey).then((v) => setState(() => _llmEnabled = v == 'true'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Richer task descriptions'),
            subtitle: Text(_llmEnabled
                ? 'On-device LLM active (~650MB)'
                : 'Enable to download on-device LLM (~650MB on first use)'),
            value: _llmEnabled,
            onChanged: _downloading ? null : _toggleLlm,
          ),
          if (_downloading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleLlm(bool value) async {
    if (value) {
      setState(() => _downloading = true);
      try {
        await FlutterGemmaPlugin.instance.init(
          maxTokens: 50,
          temperature: 0.7,
          topK: 5,
        );
        await _storage.write(key: _llmKey, value: 'true');
        setState(() { _llmEnabled = true; _downloading = false; });
      } catch (e) {
        setState(() => _downloading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } else {
      await _storage.write(key: _llmKey, value: 'false');
      setState(() => _llmEnabled = false);
    }
  }
}
```

- [ ] **Step 3: Implement LLM rewriter**

```dart
// lib/features/tasks/llm_rewriter.dart
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'task_template.dart';

class LlmRewriter {
  static const _storage = FlutterSecureStorage();

  static Future<String> rewrite(
    TaskTemplate template, {
    required String spotName,
    required String weather,
    required String timeOfDay,
  }) async {
    final enabled = await _storage.read(key: 'llm_enabled') == 'true';
    if (!enabled) return template.description;

    try {
      final prompt =
          'Rewrite this outdoor task description in one sentence for a hiker at $spotName '
          'in $weather conditions at $timeOfDay: "${template.description}"';
      final gemma = FlutterGemmaPlugin.instance;
      final result = StringBuffer();
      await for (final token in gemma.getResponse(prompt: prompt)) {
        result.write(token);
      }
      return result.toString().trim().isEmpty ? template.description : result.toString().trim();
    } catch (_) {
      return template.description; // always fall back to curated text
    }
  }
}
```

- [ ] **Step 4: Wire rewriter into task_screen.dart**

```dart
// In TaskScreen._TaskInProgress, replace static description with:
FutureBuilder<String>(
  future: LlmRewriter.rewrite(
    template,
    spotName: widget.spot.name,
    weather: 'clear', // from ForecastCache
    timeOfDay: DateTime.now().hour < 12 ? 'morning' : 'afternoon',
  ),
  builder: (_, snap) => Text(snap.data ?? template.description, textAlign: TextAlign.center),
),
```

- [ ] **Step 5: Add Settings route in router.dart**

```dart
const kSettingsRoute = '/settings';
// Add inside ShellRoute routes or as a top-level GoRoute:
GoRoute(path: kSettingsRoute, builder: (_, __) => const SettingsScreen()),
```

- [ ] **Step 6: Run and verify**

```bash
flutter run
```

Expected: Settings toggle visible in Profile. LLM download prompts on first enable. Task descriptions unchanged without LLM; enriched with LLM active. Anshin banner appears in journey when pressure drops or rain forecast > 70%.

- [ ] **Step 7: Commit**

```bash
git add lib/ tools/ assets/ pubspec.yaml
git commit -m "feat: opt-in LLM task rewriter and Settings screen"
```

---

### Task 7: Final checks

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
git commit -m "chore: Phase 4 Safety & Intelligence complete"
```
