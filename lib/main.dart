import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/auth/auth_service.dart';
import 'core/db/isar_service.dart';
import 'core/maps/tile_cache_manager.dart';
import 'features/anshin/forecast_cache.dart';
import 'features/explore/spot.dart';
import 'features/journal/journal_entry.dart';
import 'features/journey/journey.dart';
import 'features/onboarding/onboarding_gate.dart';
import 'features/persona/persona.dart';
import 'features/tasks/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  await initTileCache();
  final isar = await IsarService.open([
    PersonaSchema,
    SpotSchema,
    JourneySchema,
    TaskSchema,
    JournalEntrySchema,
    CachedForecastSchema,
  ]);
  OnboardingGate.needed = await isar.personas.where().anyId().findFirst() == null;
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
