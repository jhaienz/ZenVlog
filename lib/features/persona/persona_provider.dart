import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../onboarding/onboarding_gate.dart';
import 'persona.dart';
part 'persona_provider.g.dart';

@riverpod
class PersonaNotifier extends _$PersonaNotifier {
  @override
  Future<Persona?> build() async {
    final isar = IsarService.instance;
    return isar.personas.where().findFirst();
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

  Future<void> update(Persona updated) async {
    updated.updatedAt = DateTime.now();
    await save(updated);
  }
}
