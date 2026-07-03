# Phase 5 — Group Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Host creates a Group via BLE broadcast, members join after host approval, Merged Persona is computed, and the group sees a shared offline itinerary.

**Architecture:** `BleScanner` advertises/scans for `zen-group-v1` service → Host approves join requests → `GroupProvider` state machine manages members → Merged Persona = min(Stamina, SolitudeNeed, CulturalAffinity) + avg(Curiosity, NatureAffinity) → Serendipity Scraper runs against Merged Persona for group itinerary.

**Tech Stack:** flutter_blue_plus, Riverpod 2.x (in-memory state, no Isar persistence)

## Global Constraints

- Inherits all Phase 1–4 constraints
- Group is in-memory only — not persisted to Isar (disbanded groups have no record)
- Max group size: 6 members (BLE GATT characteristic size constraint)
- BLE service UUID for ZenVlog groups: `12345678-1234-1234-1234-123456789012`
- GATT characteristic UUID for group state: `87654321-4321-4321-4321-210987654321`
- Merged Persona merge rules: min(Stamina, SolitudeNeed, CulturalAffinity) across all members; avg(Curiosity, NatureAffinity) across all members
- Group itinerary = top 5 spots from SerendipityScraper run against Merged Persona
- `GroupStatus.dissolved` → GroupProvider.build() returns null
- BLE permissions must be requested before scanning/advertising

---

## Files

- Create: `lib/features/group/group.dart`
- Create: `lib/features/group/ble_scanner.dart`
- Create: `lib/features/group/group_provider.dart` + `.g.dart`
- Create: `lib/features/group/group_screen.dart`
- Create: `lib/features/group/group_itinerary_screen.dart`
- Create: `test/features/group/merged_persona_test.dart`
- Modify: `lib/app/router.dart` — add `/group` and `/group/itinerary` routes
- Modify: `lib/features/explore/serendipity_scraper.dart` — accept optional override persona
- Modify: `pubspec.yaml` — declare BLE permissions (done in AndroidManifest/Info.plist)

---

### Task 1: Group domain model

- [ ] **Step 1: Write test**

```dart
// test/features/group/merged_persona_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/group/group.dart';
import 'package:app/features/persona/persona.dart';

void main() {
  test('Merged Persona uses minimum for Stamina, SolitudeNeed, CulturalAffinity', () {
    final members = [
      MemberPersona(userId: 'a', displayName: 'A',
          persona: Persona.fromSliders(stamina: 0.9, curiosity: 0.6, solitudeNeed: 0.8, natureAffinity: 0.7, culturalAffinity: 0.5)),
      MemberPersona(userId: 'b', displayName: 'B',
          persona: Persona.fromSliders(stamina: 0.3, curiosity: 0.8, solitudeNeed: 0.4, natureAffinity: 0.5, culturalAffinity: 0.9)),
    ];
    final merged = Group.computeMergedPersona(members);
    expect(merged.stamina, 0.3);           // min
    expect(merged.solitudeNeed, 0.4);      // min
    expect(merged.culturalAffinity, 0.5);  // min
    expect(merged.curiosity, closeTo(0.7, 0.001)); // avg
    expect(merged.natureAffinity, closeTo(0.6, 0.001)); // avg
  });

  test('Single member merged persona equals their own persona', () {
    final persona = Persona.fromSliders(stamina: 0.7, curiosity: 0.5, solitudeNeed: 0.6, natureAffinity: 0.8, culturalAffinity: 0.3);
    final merged = Group.computeMergedPersona([MemberPersona(userId: 'a', displayName: 'A', persona: persona)]);
    expect(merged.vector, persona.vector);
  });
}
```

- [ ] **Step 2: Run to confirm fail**

```bash
flutter test test/features/group/merged_persona_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement**

```dart
// lib/features/group/group.dart
import '../persona/persona.dart';

enum GroupStatus { forming, active, dissolved }

class MemberPersona {
  final String userId;
  final String displayName;
  final Persona persona;
  const MemberPersona({required this.userId, required this.displayName, required this.persona});
}

class Group {
  final String hostId;
  final List<MemberPersona> members;
  final Persona mergedPersona;
  final GroupStatus status;

  const Group({
    required this.hostId,
    required this.members,
    required this.mergedPersona,
    required this.status,
  });

  Group copyWith({List<MemberPersona>? members, GroupStatus? status}) {
    final m = members ?? this.members;
    return Group(
      hostId: hostId,
      members: m,
      mergedPersona: computeMergedPersona(m),
      status: status ?? this.status,
    );
  }

  static Persona computeMergedPersona(List<MemberPersona> members) {
    if (members.isEmpty) return Persona();
    if (members.length == 1) return members.first.persona;

    // Constraints: minimum across members
    double minStamina = members.map((m) => m.persona.stamina).reduce((a, b) => a < b ? a : b);
    double minSolitude = members.map((m) => m.persona.solitudeNeed).reduce((a, b) => a < b ? a : b);
    double minCultural = members.map((m) => m.persona.culturalAffinity).reduce((a, b) => a < b ? a : b);

    // Preferences: average across members
    double avgCuriosity = members.map((m) => m.persona.curiosity).reduce((a, b) => a + b) / members.length;
    double avgNature = members.map((m) => m.persona.natureAffinity).reduce((a, b) => a + b) / members.length;

    return Persona.fromSliders(
      stamina: minStamina,
      curiosity: avgCuriosity,
      solitudeNeed: minSolitude,
      natureAffinity: avgNature,
      culturalAffinity: minCultural,
    );
  }

  double get harmonyScore {
    // ponytail: harmonyScore = 1 - avg pairwise euclidean distance; upgrade if UX needs refinement
    if (members.length < 2) return 1.0;
    double totalDist = 0;
    int pairs = 0;
    for (int i = 0; i < members.length; i++) {
      for (int j = i + 1; j < members.length; j++) {
        final a = members[i].persona.vector;
        final b = members[j].persona.vector;
        double dist = 0;
        for (int k = 0; k < 5; k++) dist += (a[k] - b[k]) * (a[k] - b[k]);
        totalDist += (dist / 5).clamp(0.0, 1.0);
        pairs++;
      }
    }
    return (1.0 - totalDist / pairs).clamp(0.0, 1.0);
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/group/merged_persona_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/group/group.dart test/features/group/
git commit -m "feat: Group domain model with Merged Persona computation"
```

---

### Task 2: BleScanner

- [ ] **Step 1: Add BLE permissions**

In `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

In `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>ZenVlog uses Bluetooth to connect with your hiking group offline.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>ZenVlog uses Bluetooth to share preferences with your group.</string>
```

- [ ] **Step 2: Implement BleScanner**

```dart
// lib/features/group/ble_scanner.dart
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const _serviceUuid = '12345678-1234-1234-1234-123456789012';
const _characteristicUuid = '87654321-4321-4321-4321-210987654321';

class BleScanner {
  static final FlutterBluePlus _ble = FlutterBluePlus.instance;

  /// Broadcasts this device as a group host. Returns advertiser handle.
  static Future<void> startAdvertising(String hostId, Map<String, dynamic> groupState) async {
    // flutter_blue_plus peripheral mode — available on iOS/Android
    // Note: Android requires a real device (emulator BLE advertising is unsupported)
    await FlutterBluePlus.startAdvertising(
      localName: 'ZenGroup:$hostId',
      serviceUuids: [Guid(_serviceUuid)],
    );
  }

  static Future<void> stopAdvertising() => FlutterBluePlus.stopAdvertising();

  /// Scans for nearby ZenVlog group hosts. Emits (hostId, deviceId) pairs.
  static Stream<({String hostId, BluetoothDevice device})> scanForGroups() async* {
    await FlutterBluePlus.startScan(
      withServices: [Guid(_serviceUuid)],
      timeout: const Duration(seconds: 10),
    );
    await for (final result in FlutterBluePlus.scanResults) {
      for (final r in result) {
        final name = r.device.platformName;
        if (name.startsWith('ZenGroup:')) {
          final hostId = name.substring('ZenGroup:'.length);
          yield (hostId: hostId, device: r.device);
        }
      }
    }
  }

  /// Reads group state from host's GATT characteristic.
  static Future<Map<String, dynamic>?> readGroupState(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 5));
    try {
      final services = await device.discoverServices();
      final service = services.firstWhere((s) => s.uuid == Guid(_serviceUuid));
      final char = service.characteristics.firstWhere((c) => c.uuid == Guid(_characteristicUuid));
      final bytes = await char.read();
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } finally {
      await device.disconnect();
    }
  }

  /// Writes updated group state to GATT characteristic (host only).
  static Future<void> writeGroupState(BluetoothDevice device, Map<String, dynamic> state) async {
    final services = await device.discoverServices();
    final service = services.firstWhere((s) => s.uuid == Guid(_serviceUuid));
    final char = service.characteristics.firstWhere((c) => c.uuid == Guid(_characteristicUuid));
    await char.write(utf8.encode(jsonEncode(state)));
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/group/ble_scanner.dart android/ ios/
git commit -m "feat: BleScanner advertise and scan for ZenVlog groups"
```

---

### Task 3: GroupProvider

- [ ] **Step 1: Implement**

```dart
// lib/features/group/group_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/identity/local_identity.dart';
import '../persona/persona_provider.dart';
import 'group.dart';
import 'ble_scanner.dart';
part 'group_provider.g.dart';

@riverpod
class GroupNotifier extends _$GroupNotifier {
  @override
  Group? build() => null;

  Future<void> startAsHost() async {
    final myId = await LocalIdentity.current;
    final myPersona = await ref.read(personaNotifierProvider.future);
    if (myPersona == null) return;

    final me = MemberPersona(userId: myId, displayName: 'You', persona: myPersona);
    state = Group(
      hostId: myId,
      members: [me],
      mergedPersona: Group.computeMergedPersona([me]),
      status: GroupStatus.forming,
    );

    await BleScanner.startAdvertising(myId, _serializeState());
  }

  void approveMember(MemberPersona newMember) {
    final current = state;
    if (current == null || current.members.length >= 6) return;
    state = current.copyWith(members: [...current.members, newMember]);
    // Re-broadcast updated state to all connected members
    BleScanner.startAdvertising(current.hostId, _serializeState());
  }

  void activateGroup() {
    state = state?.copyWith(status: GroupStatus.active);
  }

  void dissolve() {
    BleScanner.stopAdvertising();
    state = null;
  }

  Map<String, dynamic> _serializeState() {
    final g = state;
    if (g == null) return {};
    return {
      'hostId': g.hostId,
      'members': g.members.map((m) => {
        'userId': m.userId,
        'displayName': m.displayName,
        'persona': m.persona.vector,
      }).toList(),
      'status': g.status.name,
    };
  }
}
```

- [ ] **Step 2: Generate**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/group/group_provider.dart
git commit -m "feat: GroupNotifier BLE-backed state machine"
```

---

### Task 4: Group screen and itinerary

- [ ] **Step 1: Update SerendipityScraper to accept optional persona override**

```dart
// In lib/features/explore/serendipity_scraper.dart
// Modify findHiddenSpots signature:
static Future<List<Spot>> findHiddenSpots(Persona persona, {Persona? overridePersona}) async {
  final effectivePersona = overridePersona ?? persona;
  final isar = IsarService.instance;
  final candidates = await isar.spots
      .filter()
      .tagDensityLessThan(_tagDensityThreshold)
      .findAll();
  return filterAndRank(candidates, effectivePersona);
}
```

- [ ] **Step 2: Implement GroupScreen**

```dart
// lib/features/group/group_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../persona/persona_provider.dart';
import 'group.dart';
import 'group_provider.dart';

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupNotifierProvider);
    if (group == null) return _NoGroupView();
    return _GroupView(group: group);
  }
}

class _NoGroupView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Group Sync')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Start or join a hiking group'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(groupNotifierProvider.notifier).startAsHost(),
                child: const Text('Start Group'),
              ),
            ],
          ),
        ),
      );
}

class _GroupView extends ConsumerWidget {
  final Group group;
  const _GroupView({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text('${group.members.length} members · Bluetooth Mesh'),
          actions: [
            TextButton(
              onPressed: () => ref.read(groupNotifierProvider.notifier).dissolve(),
              child: const Text('Leave', style: TextStyle(color: Color(0xFFD4A853))),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Group Harmony'),
                  Text('${(group.harmonyScore * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Color(0xFFD4A853), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: group.harmonyScore,
              backgroundColor: const Color(0xFF243D30),
              color: const Color(0xFFD4A853),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: group.members.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Text(group.members[i].displayName[0])),
                  title: Text(group.members[i].displayName),
                  subtitle: Text(
                    'Stamina ${(group.members[i].persona.stamina * 100).toInt()}% · '
                    'Solitude ${(group.members[i].persona.solitudeNeed * 100).toInt()}%',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(groupNotifierProvider.notifier).activateGroup();
                    context.push(kGroupItineraryRoute);
                  },
                  child: const Text('View Group Itinerary'),
                ),
              ),
            ),
          ],
        ),
      );
}
```

- [ ] **Step 3: Implement Group Itinerary screen**

```dart
// lib/features/group/group_itinerary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../explore/serendipity_scraper.dart';
import '../explore/spot.dart';
import '../persona/persona_provider.dart';
import 'group_provider.dart';

class GroupItineraryScreen extends ConsumerStatefulWidget {
  const GroupItineraryScreen({super.key});
  @override
  ConsumerState<GroupItineraryScreen> createState() => _GroupItineraryScreenState();
}

class _GroupItineraryScreenState extends ConsumerState<GroupItineraryScreen> {
  List<Spot> _spots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    final group = ref.read(groupNotifierProvider);
    final myPersona = await ref.read(personaNotifierProvider.future);
    if (myPersona == null) return;

    final effectivePersona = group?.mergedPersona ?? myPersona;
    final spots = await SerendipityScraper.findHiddenSpots(myPersona, overridePersona: effectivePersona);
    if (mounted) setState(() { _spots = spots.take(5).toList(); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Itinerary')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF243D30),
                  child: const Row(
                    children: [
                      Icon(Icons.bluetooth, color: Color(0xFFD4A853), size: 16),
                      SizedBox(width: 8),
                      Text('Offline Mode · Preferences merged', style: TextStyle(color: Color(0xFFF5F0E8))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _spots.length,
                    itemBuilder: (_, i) {
                      final spot = _spots[i];
                      final hour = 7 + i * 2;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF243D30),
                          child: Text('${hour.toString().padLeft(2, '0')}:00',
                              style: const TextStyle(color: Color(0xFFD4A853), fontSize: 11)),
                        ),
                        title: Text(spot.name),
                        subtitle: Text(spot.osmTags.take(2).join(' · ')),
                        trailing: Text('Score: ${spot.personaScore.toStringAsFixed(1)}',
                            style: const TextStyle(color: Color(0xFFD4A853))),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(kJourneyActiveRoute, extra: _spots.first),
                      child: const Text('Start Journey'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
```

- [ ] **Step 4: Add routes to router.dart**

```dart
const kGroupRoute = '/group';
const kGroupItineraryRoute = '/group/itinerary';

// Add inside ShellRoute routes:
GoRoute(path: kGroupRoute, builder: (_, __) => const GroupScreen()),
GoRoute(path: kGroupItineraryRoute, builder: (_, __) => const GroupItineraryScreen()),
```

- [ ] **Step 5: Run and test**

```bash
flutter run
```

Expected: Group screen shows "Start Group" → tapping creates a group with host → "View Group Itinerary" → 5 spots ranked by Merged Persona visible.

Note: BLE testing with two real devices is needed to test the full join flow. On single device/emulator, verify the solo itinerary path works.

- [ ] **Step 6: Commit**

```bash
git add lib/features/group/ lib/app/router.dart lib/features/explore/serendipity_scraper.dart
git commit -m "feat: BLE group sync with Merged Persona and shared offline itinerary"
```

---

### Task 5: Final checks

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
git commit -m "chore: Phase 5 Group complete"
```
