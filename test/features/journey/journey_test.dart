import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/journey/journey.dart';

void main() {
  test('Journey.isActive is true when endTime is null', () {
    final j = Journey()..startTime = DateTime.now();
    expect(j.isActive, isTrue);
  });

  test('Journey.isActive is false after endTime set', () {
    final j = Journey()
      ..startTime = DateTime.now()
      ..endTime = DateTime.now().add(const Duration(hours: 2));
    expect(j.isActive, isFalse);
  });

  test('Journey.durationHours calculates correctly', () {
    final start = DateTime(2026, 1, 1, 9, 0);
    final end = DateTime(2026, 1, 1, 11, 30);
    final j = Journey()
      ..startTime = start
      ..endTime = end;
    expect(j.durationHours, closeTo(2.5, 0.01));
  });
}
