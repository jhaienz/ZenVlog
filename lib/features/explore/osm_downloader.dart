import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/db/isar_service.dart';
import 'spot.dart';

class OsmDownloader {
  // Overpass API — free, no key required. Mirrors tried in order;
  // overpass-api.de rate-limits (429) aggressively.
  static const _overpassMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  /// Downloads natural features for the bounding box and stores them as Spots.
  /// No-ops if any Spots already exist.
  // ponytail: single-region cache; track per-bbox coverage if multi-region needed
  static Future<int> downloadRegion(
      double south, double west, double north, double east) async {
    final isar = IsarService.instance;
    final existing = await isar.spots.count();
    if (existing > 0) return existing;

    final query = '''
[out:json][timeout:25];
(
  node["natural"~"water|wood|peak|grassland|cliff|cave_entrance"]($south,$west,$north,$east);
  way["natural"~"water|wood|peak|grassland|cliff|cave_entrance"]($south,$west,$north,$east);
);
out center;
''';

    http.Response? response;
    Object? lastError;
    for (final mirror in _overpassMirrors) {
      try {
        response = await http
            .post(Uri.parse(mirror), body: {'data': query})
            .timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) break;
        lastError = 'HTTP ${response.statusCode} from ${Uri.parse(mirror).host}';
        response = null;
      } catch (e) {
        lastError = e;
        response = null;
      }
    }
    if (response == null) {
      throw Exception('OSM download failed: $lastError');
    }

    final elements = (jsonDecode(response.body)['elements'] as List)
        .cast<Map<String, dynamic>>();
    final spots = elements.map(_toSpot).whereType<Spot>().toList();

    await isar.writeTxn(() => isar.spots.putAll(spots));
    return spots.length;
  }

  static Spot? _toSpot(Map<String, dynamic> el) {
    final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
    final lat = ((el['lat'] ?? el['center']?['lat']) as num?)?.toDouble();
    final lng = ((el['lon'] ?? el['center']?['lon']) as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    final osmTags = tags.entries
        .where((e) =>
            ['natural', 'water', 'tourism', 'amenity', 'leisure'].contains(e.key))
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
