import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Isar opens in Phase 2 when the first collection schema exists.
  await AuthService.initialize();
  runApp(const ProviderScope(child: _App()));
}

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'ZenVlog',
        theme: zenvlogTheme,
        routerConfig: router,
      );
}
