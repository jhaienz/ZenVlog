import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:app/app/router.dart';
import 'package:app/app/theme.dart';
import 'package:app/core/auth/auth_service.dart';
import 'package:app/core/db/isar_service.dart';
import 'package:app/features/explore/spot.dart';
import 'package:app/features/journal/journal_entry.dart';
import 'package:app/features/journey/journey.dart';
import 'package:app/features/onboarding/onboarding_gate.dart';
import 'package:app/features/persona/persona.dart';
import 'package:app/features/tasks/task.dart';

void main() {
  Widget app() => ProviderScope(
      child: MaterialApp.router(theme: zenvlogTheme, routerConfig: router));

  late Directory tempDir;

  setUpAll(() async {
    // libisar.so lives at the repo root (downloaded by earlier test runs)
    await Isar.initializeIsarCore(download: false);
    tempDir = Directory.systemTemp.createTempSync('zenvlog_widget_test');
    await IsarService.open(
      [PersonaSchema, SpotSchema, JourneySchema, TaskSchema, JournalEntrySchema],
      directory: tempDir.path,
    );
  });

  tearDownAll(() async {
    await IsarService.close();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() => OnboardingGate.needed = false);
  tearDown(() => AuthService.debugSignedInOverride = null);

  testWidgets('signed-in user without persona is redirected to onboarding', (tester) async {
    AuthService.debugSignedInOverride = true;
    OnboardingGate.needed = true;
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Design your mindful adventure'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('unauthenticated user is redirected to sign-in', (tester) async {
    AuthService.debugSignedInOverride = false;
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('ZenVlog'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('signed-in shell shows 4 tabs with Home active', (tester) async {
    AuthService.debugSignedInOverride = true;
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Home is the initial tab. The other tab screens run Isar queries or
    // rootBundle loads, which never complete under the fake-async test
    // binding (and a pending query hangs Isar close in teardown), so tab
    // navigation is exercised on-device instead.
    expect(find.text('Design your mindful adventure'), findsOneWidget);
    final bar = find.byType(BottomNavigationBar);
    for (final tab in ['Home', 'Explore', 'Journal', 'Profile']) {
      expect(find.descendant(of: bar, matching: find.text(tab)),
          findsOneWidget);
    }
  });
}
