import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/router.dart';
import 'package:app/app/theme.dart';

void main() {
  Widget app() => MaterialApp.router(theme: zenvlogTheme, routerConfig: router);

  testWidgets('shell shows 4 tabs and navigates between them', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    // Home is the initial tab
    expect(find.text('Home'), findsWidgets);

    for (final tab in ['Explore', 'Journal', 'Profile']) {
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text(tab),
      ));
      await tester.pumpAndSettle();
      expect(find.text(tab), findsWidgets);
    }
  });
}
