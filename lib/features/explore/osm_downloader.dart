import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/db/isar_service.dart';
import 'spot.dart';

class OsmDownloader {
  // Overpass API — free, no key required
  static const _overpassUrl = 'https://overpass-api.de/api/interpreter';

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

    final response = await http.post(
      Uri.parse(_overpassUrl),
      body: {'data': query},
    );
    if (response.statusCode != 200) {
      throw Exception('OSM download failed: ${response.statusCode}');
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
