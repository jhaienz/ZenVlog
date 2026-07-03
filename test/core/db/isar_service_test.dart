import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/db/isar_service.dart';

void main() {
  // Isar requires at least one collection schema to open, and Phase 1 has no
  // models yet — open() is exercised by Phase 2 tests with real schemas.
  test('IsarService.instance asserts when open() has not been called', () {
    expect(() => IsarService.instance, throwsA(isA<AssertionError>()));
  });
}
