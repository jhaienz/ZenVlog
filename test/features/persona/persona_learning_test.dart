import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/persona/persona.dart';
import 'package:app/features/persona/persona_learning.dart';
import 'package:app/features/journey/journey.dart';

Persona _mid() => Persona.fromSliders(
      stamina: 0.5,
      curiosity: 0.5,
      solitudeNeed: 0.5,
      natureAffinity: 0.5,
      culturalAffinity: 0.5,
    );

Journey _journey({double distanceM = 5000}) => Journey()
  ..startTime = DateTime(2026, 1, 1, 9)
  ..endTime = DateTime(2026, 1, 1, 12)
  ..totalDistanceM = distanceM;

void main() {
  test('no update before 5 completed journeys', () {
    final p = _mid()..completedJourneys = 3;
    final before = p.vector;
    PersonaLearning.apply(p, _journey(), acceptedTasks: 3, completedTasks: 3);
    expect(p.vector, before);
  });

  test('long journeys pull stamina up', () {
    final p = _mid()..completedJourneys = 5;
    PersonaLearning.apply(p, _journey(distanceM: 12000),
        acceptedTasks: 0, completedTasks: 0);
    expect(p.stamina, greaterThan(0.5));
  });

  test('short journeys pull stamina down', () {
    final p = _mid()..completedJourneys = 5;
    PersonaLearning.apply(p, _journey(distanceM: 500),
        acceptedTasks: 0, completedTasks: 0);
    expect(p.stamina, lessThan(0.5));
  });

  test('completing accepted tasks pulls nature affinity up', () {
    final p = _mid()..completedJourneys = 5;
    PersonaLearning.apply(p, _journey(), acceptedTasks: 3, completedTasks: 3);
    expect(p.natureAffinity, greaterThan(0.5));
  });

  test('values stay clamped to [0,1]', () {
    final p = Persona.fromSliders(
      stamina: 0.99,
      curiosity: 0.99,
      solitudeNeed: 0.99,
      natureAffinity: 0.99,
      culturalAffinity: 0.99,
    )..completedJourneys = 5;
    for (var i = 0; i < 50; i++) {
      PersonaLearning.apply(p, _journey(distanceM: 20000),
          acceptedTasks: 3, completedTasks: 3);
    }
    expect(p.stamina, lessThanOrEqualTo(1.0));
    expect(p.natureAffinity, lessThanOrEqualTo(1.0));
  });
}
