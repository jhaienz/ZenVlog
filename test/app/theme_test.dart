import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/theme.dart';
import 'package:flutter/material.dart';

void main() {
  test('primary color is forest green', () {
    expect(zenvlogTheme.colorScheme.primary, const Color(0xFF1A3A2A));
  });

  test('card color is cream', () {
    expect(zenvlogTheme.cardColor, const Color(0xFFF5F0E8));
  });
}
