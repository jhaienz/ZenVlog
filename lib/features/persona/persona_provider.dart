import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../journey/journey.dart';
import '../onboarding/onboarding_gate.dart';
import '../tasks/task.dart';
import 'persona.dart';
import 'persona_learning.dart';
part 'persona_provider.g.dart';

@riverpod
class PersonaNotifier extends _$PersonaNotifier {
  @override
  Future<Persona?> build() async {
    final isar = IsarService.instance;
    return isar.personas.where().anyId().findFirst();
  }

  Future<void> save(Persona persona) async {
    final isar = IsarService.instance;
    await isar.writeTxn(() async {
      await isar.personas.clear();
      await isar.personas.put(persona);
    });
    OnboardingGate.needed = false;
    state = AsyncData(persona);
  }

  /// Called when a Journey ends: counts it and, past 5 journeys, refines
  /// the Persona from observed behavior.
  Future<void> recordCompletedJourney(Journey journey) async {
    final persona = state.value;
    if (persona == null) return;

    final isar = IsarService.instance;
    final tasks =
        await isar.tasks.filter().journeyIdEqualTo(journey.id).findAll();

    persona.completedJourneys++;
    PersonaLearning.apply(
      persona,
      journey,
      acceptedTasks: tasks.length,
      completedTasks: tasks.where((t) => t.isCompleted).length,
    );
    await save(persona);
  }
}
