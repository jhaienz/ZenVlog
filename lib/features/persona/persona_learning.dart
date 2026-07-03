import '../journey/journey.dart';
import 'persona.dart';

/// Behavioral persona refinement: after 5+ completed journeys, each new
/// journey nudges the Persona toward observed behavior via an exponential
/// moving average (learning rate 0.1).
///
/// ponytail: hand-written EMA instead of the planned TFLite model — the
/// model was to be trained on synthetic data encoding exactly these
/// rules, so the rules ship directly. Revisit ML when real usage data
/// exists to train on.
class PersonaLearning {
  static const _lr = 0.1;
  static const _minJourneys = 5;

  static void apply(
    Persona persona,
    Journey journey, {
    required int acceptedTasks,
    required int completedTasks,
  }) {
    if (persona.completedJourneys < _minJourneys) return;

    // Observed stamina: 10 km in a journey = 1.0.
    final observedStamina =
        (journey.totalDistanceM / 10000).clamp(0.0, 1.0);
    persona.stamina = _ema(persona.stamina, observedStamina);

    // Observed engagement with place (nature affinity + curiosity proxy):
    // accepting and finishing tasks signals engagement with the spot.
    if (acceptedTasks > 0) {
      final completionRatio =
          (completedTasks / acceptedTasks).clamp(0.0, 1.0);
      persona.natureAffinity =
          _ema(persona.natureAffinity, completionRatio);
      persona.curiosity =
          _ema(persona.curiosity, (acceptedTasks / 3).clamp(0.0, 1.0));
    }

    // Early starts signal solitude seeking (quiet hours).
    if (journey.startTime.hour < 8) {
      persona.solitudeNeed = _ema(persona.solitudeNeed, 1.0);
    }

    persona.updatedAt = DateTime.now();
  }

  static double _ema(double current, double observed) =>
      ((1 - _lr) * current + _lr * observed).clamp(0.0, 1.0);
}
