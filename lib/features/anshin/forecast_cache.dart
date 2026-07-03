import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import '../../core/db/isar_service.dart';

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

  /// Hours until forecast shows >70% precipitation probability within the
  /// next 6 hours; null if none.
  static int? rainAlertHours(Map<String, dynamic> forecast) {
    final hourly = (forecast['hourly']?['precipitation_probability'] as List?)
            ?.cast<num>()
            .take(6)
            .toList() ??
        [];
    for (var i = 0; i < hourly.length; i++) {
      if (hourly[i] > 70) return i + 1;
    }
    return null;
  }

  /// Downloads a 48h forecast unless a fresh one is already cached.
  /// Returns the cached row either way; keeps the stale row on failure.
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
    } catch (_) {
      // offline — stale cache is better than nothing
    }
    return existing ?? CachedForecast();
  }

  static Future<CachedForecast?> getCached() =>
      IsarService.instance.cachedForecasts.get(1);

  static Map<String, dynamic>? parse(CachedForecast cached) {
    if (cached.data == '{}') return null;
    return jsonDecode(cached.data) as Map<String, dynamic>;
  }
}
