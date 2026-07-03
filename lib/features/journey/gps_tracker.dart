import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class GpsTracker {
  static final _location = Location();
  static const _distanceCalc = Distance();

  static Stream<LatLng> get stream async* {
    await _location.requestPermission();
    await _location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 5000, distanceFilter: 10);
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
