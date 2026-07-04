import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../../core/db/isar_service.dart';
import '../../core/net/doh_client.dart';
import 'spot.dart';

class OsmDownloader {
  // Overpass API — free, no key required. Instances on distinct domains /
  // infrastructure so a single ISP DNS failure can't take them all out.
  // overpass-api.de intermittently refuses (406/429), so we retry rounds.
  static const _overpassMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.openstreetmap.fr/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];
  static const _retryRounds = 2;

  static const _cacheMaxAge = Duration(days: 7);

  /// Downloads natural features for the bounding box and stores them as Spots.
  /// Skips the network while cached spots inside the bbox are fresh (< 7 days).
  static Future<int> downloadRegion(
      double south, double west, double north, double east) async {
    final isar = IsarService.instance;
    final cached = await isar.spots
        .filter()
        .latBetween(south, north)
        .lngBetween(west, east)
        .findAll();
    if (cached.isNotEmpty &&
        cached
            .map((s) => s.discoveredAt)
            .reduce((a, b) => a.isAfter(b) ? a : b)
            .isAfter(DateTime.now().subtract(_cacheMaxAge))) {
      return cached.length;
    }

    final query = '''
[out:json][timeout:25];
(
  node["natural"~"water|wood|peak|grassland|cliff|cave_entrance"]($south,$west,$north,$east);
  way["natural"~"water|wood|peak|grassland|cliff|cave_entrance"]($south,$west,$north,$east);
);
out center;
''';

    String? responseBody;
    Object? lastError;
    var sawDnsFailure = false;
    outer:
    for (var round = 0; round < _retryRounds; round++) {
      if (round > 0) await Future.delayed(Duration(seconds: 2 * round));
      for (final mirror in _overpassMirrors) {
        try {
          final response = await http
              .post(Uri.parse(mirror), body: {'data': query})
              .timeout(const Duration(seconds: 30));
          if (response.statusCode == 200) {
            responseBody = response.body;
            break outer;
          }
          lastError =
              'HTTP ${response.statusCode} from ${Uri.parse(mirror).host}';
        } on SocketException catch (e) {
          sawDnsFailure = true;
          lastError = e;
        } catch (e) {
          lastError = e;
        }
      }
    }

    // Carrier DNS blocks overpass domains on some networks (browser works
    // via its own DoH). Resolve via 1.1.1.1 and connect by IP.
    if (responseBody == null && sawDnsFailure) {
      const host = 'overpass-api.de';
      try {
        final ips = await DohClient.resolveAll(host);
        responseBody = await DohClient.post(
          host: host,
          path: '/api/interpreter',
          ips: ips,
          formBody: {'data': query},
        );
      } catch (e) {
        lastError = 'DoH fallback: $e (direct: $lastError)';
      }
    }

    if (responseBody == null) {
      throw Exception('OSM download failed after retries: $lastError');
    }

    final elements = (jsonDecode(responseBody)['elements'] as List)
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
