import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'anshin_alert.dart';

/// Static hazard zones bundled as GeoJSON. No network fetch — data ships
/// with the app (ADR-0003).
class HazardOverlay {
  static List<Map<String, dynamic>>? _cache;

  static Future<List<Map<String, dynamic>>> _features() async {
    if (_cache != null) return _cache!;
    final data =
        await rootBundle.loadString('assets/hazards/hazard_zones.geojson');
    final fc = jsonDecode(data) as Map<String, dynamic>;
    _cache = List<Map<String, dynamic>>.from(fc['features'] as List);
    return _cache!;
  }

  static Future<PolygonLayer> buildLayer() async {
    final features = await _features();
    final polygons = features
        .where((f) => (f['geometry'] as Map)['type'] == 'Polygon')
        .map((f) {
      final coords =
          ((f['geometry'] as Map)['coordinates'] as List).first as List;
      final points = coords
          .map((c) =>
              LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      final danger = (f['properties'] as Map)['severity'] == 'danger';
      return Polygon(
        points: points,
        color: (danger ? Colors.red : Colors.orange).withValues(alpha: 0.2),
        borderColor: danger ? Colors.red : Colors.orange,
        borderStrokeWidth: 2,
      );
    }).toList();
    return PolygonLayer(polygons: polygons);
  }

  static Future<List<AnshinAlert>> checkPosition(double lat, double lng) async {
    final features = await _features();
    return checkPositionIn(features, lat, lng);
  }

  /// Pure logic — testable without asset bundle.
  // ponytail: bounding-box check, not point-in-polygon; upgrade to ray
  // casting if hazard shapes stop being roughly rectangular
  static List<AnshinAlert> checkPositionIn(
      List<Map<String, dynamic>> features, double lat, double lng) {
    final alerts = <AnshinAlert>[];
    for (final f in features) {
      final geo = f['geometry'] as Map<String, dynamic>;
      if (geo['type'] != 'Polygon') continue;
      final coords = (geo['coordinates'] as List).first as List;
      final lats = coords.map((c) => (c[1] as num).toDouble());
      final lngs = coords.map((c) => (c[0] as num).toDouble());
      final inBox = lat >= lats.reduce((a, b) => a < b ? a : b) &&
          lat <= lats.reduce((a, b) => a > b ? a : b) &&
          lng >= lngs.reduce((a, b) => a < b ? a : b) &&
          lng <= lngs.reduce((a, b) => a > b ? a : b);
      if (inBox) {
        final props = f['properties'] as Map<String, dynamic>;
        alerts.add(AnshinAlert(
          type: AlertType.hazard,
          message: props['name'] as String? ?? 'Hazard zone',
          severity: props['severity'] == 'danger'
              ? AlertSeverity.danger
              : AlertSeverity.warning,
          createdAt: DateTime.now(),
        ));
      }
    }
    return alerts;
  }
}
