import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/anshin/anshin_alert.dart';
import 'package:app/features/anshin/hazard_overlay.dart';

final _zone = {
  'type': 'Feature',
  'properties': {'type': 'flood_zone', 'severity': 'warning', 'name': 'Test flood plain'},
  'geometry': {
    'type': 'Polygon',
    'coordinates': [
      [
        [123.10, 13.55],
        [123.25, 13.55],
        [123.25, 13.65],
        [123.10, 13.65],
        [123.10, 13.55],
      ]
    ],
  },
};

void main() {
  test('position inside hazard zone produces alert', () {
    final alerts = HazardOverlay.checkPositionIn([_zone], 13.60, 123.18);
    expect(alerts.length, 1);
    expect(alerts.first.type, AlertType.hazard);
    expect(alerts.first.severity, AlertSeverity.warning);
    expect(alerts.first.message, 'Test flood plain');
  });

  test('position outside hazard zone produces no alert', () {
    final alerts = HazardOverlay.checkPositionIn([_zone], 14.0, 124.0);
    expect(alerts, isEmpty);
  });
}
