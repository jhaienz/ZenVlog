/// Router gate: true until a Persona exists in Isar.
/// Set from main() at startup; cleared by PersonaNotifier.save().
class OnboardingGate {
  static bool needed = true;
}
