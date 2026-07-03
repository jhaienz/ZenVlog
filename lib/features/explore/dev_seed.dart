import 'dart:math';
import '../../core/db/isar_service.dart';
import 'spot.dart';

/// Dev-only: seeds fake Hidden Spots around a center when the OSM
/// download fails (device network issues). Lets the full journey loop
/// be tested without Overpass. Never runs in prod.
class DevSeed {
  static const _natures = [
    ['natural=water', 'Quiet Stream'],
    ['natural=wood', 'Shaded Grove'],
    ['natural=peak', 'Small Rise'],
    ['natural=grassland', 'Open Meadow'],
    ['natural=cliff', 'Stone Ledge'],
    ['natural=cave_entrance', 'Hollow Mouth'],
  ];

  static Future<int> seedAround(double lat, double lng) async {
    final isar = IsarService.instance;
    final rng = Random(42);
    final spots = List.generate(12, (i) {
      final n = _natures[i % _natures.length];
      return Spot()
        ..osmId = 'dev_seed_$i'
        ..name = '${n[1]} ${i + 1} (dev)'
        ..lat = lat + (rng.nextDouble() - 0.5) * 0.04
        ..lng = lng + (rng.nextDouble() - 0.5) * 0.04
        ..osmTags = [n[0]]
        ..tagDensity = 1 + rng.nextInt(3);
    });
    await isar.writeTxn(() => isar.spots.putAll(spots));
    return spots.length;
  }
}
