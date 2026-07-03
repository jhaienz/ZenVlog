import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import 'gps_tracker.dart';
import 'journey.dart';
part 'journey_provider.g.dart';

@riverpod
class JourneyNotifier extends _$JourneyNotifier {
  StreamSubscription<dynamic>? _gpsSub;

  @override
  Future<Journey?> build() async {
    ref.onDispose(() => _gpsSub?.cancel());
    final isar = IsarService.instance;
    final active =
        await isar.journeys.filter().endTimeIsNull().findFirst();
    if (active != null) _track(active);
    return active;
  }

  Future<Journey> start(double lat, double lng, {String? spotId}) async {
    final isar = IsarService.instance;
    final journey = Journey()
      ..startTime = DateTime.now()
      ..weatherSnapshot = await _fetchWeather(lat, lng)
      ..spotIds = [if (spotId != null) spotId];
    await isar.writeTxn(() => isar.journeys.put(journey));
    state = AsyncData(journey);
    _track(journey);
    return journey;
  }

  void _track(Journey journey) {
    _gpsSub?.cancel();
    _gpsSub = GpsTracker.stream.listen((point) async {
      journey.trackLats.add(point.latitude);
      journey.trackLngs.add(point.longitude);
      journey.totalDistanceM =
          GpsTracker.distanceBetween(journey.trackLats, journey.trackLngs);
      final isar = IsarService.instance;
      await isar.writeTxn(() => isar.journeys.put(journey));
      state = AsyncData(journey);
    });
  }

  Future<Journey> end() async {
    final journey = state.value!;
    await _gpsSub?.cancel();
    _gpsSub = null;
    journey.endTime = DateTime.now();
    final isar = IsarService.instance;
    await isar.writeTxn(() => isar.journeys.put(journey));
    state = const AsyncData(null);
    return journey;
  }

  static Future<String> _fetchWeather(double lat, double lng) async {
    try {
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng'
          '&hourly=temperature_2m,precipitation_probability,windspeed_10m'
          '&forecast_days=2';
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return res.body;
    } catch (_) {
      // offline start is a supported path
    }
    return '{}';
  }
}
