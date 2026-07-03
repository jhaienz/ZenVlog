import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/anshin/forecast_cache.dart';

void main() {
  test('isStale true when cached more than 6 hours ago', () {
    final old = DateTime.now().subtract(const Duration(hours: 7));
    expect(ForecastCache.isStale(old), isTrue);
  });

  test('isStale false when cached within 6 hours', () {
    final recent = DateTime.now().subtract(const Duration(hours: 2));
    expect(ForecastCache.isStale(recent), isFalse);
  });

  test('rainAlertHours finds first hour with >70% precipitation', () {
    final forecast = {
      'hourly': {
        'precipitation_probability': [10, 20, 85, 90, 30],
      },
    };
    expect(ForecastCache.rainAlertHours(forecast), 3);
  });

  test('rainAlertHours null when no heavy rain forecast', () {
    final forecast = {
      'hourly': {
        'precipitation_probability': [10, 20, 30],
      },
    };
    expect(ForecastCache.rainAlertHours(forecast), isNull);
  });
}
