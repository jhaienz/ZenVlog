import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'anshin_alert.dart';
import 'forecast_cache.dart';
import 'hazard_overlay.dart';

part 'anshin_engine.g.dart';

/// The Anshin Engine: merges pre-cached forecast, static hazard zones,
/// and (where the device has one) barometer pressure trend into a stream
/// of alerts for the active journey position.
@riverpod
Stream<List<AnshinAlert>> anshinAlerts(
    AnshinAlertsRef ref, double lat, double lng) async* {
  final alerts = <AnshinAlert>[];

  final cached = await ForecastCache.getCached();
  if (cached != null) {
    final forecast = ForecastCache.parse(cached);
    if (forecast != null) {
      final rainIn = ForecastCache.rainAlertHours(forecast);
      if (rainIn != null) {
        alerts.add(AnshinAlert(
          type: AlertType.weather,
          message:
              'Heavy rain expected in your area within $rainIn hour${rainIn == 1 ? '' : 's'}.',
          severity: AlertSeverity.warning,
          createdAt: DateTime.now(),
        ));
      }
    }
    if (ForecastCache.isStale(cached.cachedAt) && cached.data != '{}') {
      alerts.add(AnshinAlert(
        type: AlertType.staleData,
        message:
            'Weather data is ${DateTime.now().difference(cached.cachedAt).inHours}h old. Update before your next trip.',
        severity: AlertSeverity.warning,
        createdAt: DateTime.now(),
      ));
    }
  }

  alerts.addAll(await HazardOverlay.checkPosition(lat, lng));
  yield List.unmodifiable(alerts);

  // Barometer trend: >2 hPa drop inside the sampling window = storm cell
  // approaching. Devices without a barometer end the stream silently.
  final window = <double>[];
  try {
    await for (final event in barometerEventStream()) {
      window.add(event.pressure);
      if (window.length > 24) window.removeAt(0);
      if (window.length >= 24 && window.first - window.last > 2.0) {
        yield List.unmodifiable([
          ...alerts.where((a) => a.type != AlertType.barometer),
          AnshinAlert(
            type: AlertType.barometer,
            message:
                'Rapid pressure drop detected. Conditions may deteriorate soon.',
            severity: AlertSeverity.warning,
            createdAt: DateTime.now(),
          ),
        ]);
        window.clear();
      }
    }
  } catch (_) {
    // no barometer on this device — forecast + hazard alerts already emitted
  }
}
