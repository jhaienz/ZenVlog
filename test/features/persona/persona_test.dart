import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/persona/persona.dart';

void main() {
  test('Persona.fromSliders sets all fields correctly', () {
    final p = Persona.fromSliders(
      stamina: 0.8,
      curiosity: 0.6,
      solitudeNeed: 0.9,
      natureAffinity: 0.7,
      culturalAffinity: 0.4,
    );
    expect(p.stamina, 0.8);
    expect(p.curiosity, 0.6);
    expect(p.solitudeNeed, 0.9);
    expect(p.natureAffinity, 0.7);
    expect(p.culturalAffinity, 0.4);
  });

  test('Persona.vector returns 5-element list in correct order', () {
    final p = Persona.fromSliders(
      stamina: 0.1,
      curiosity: 0.2,
      solitudeNeed: 0.3,
      natureAffinity: 0.4,
      culturalAffinity: 0.5,
    );
    expect(p.vector, [0.1, 0.2, 0.3, 0.4, 0.5]);
  });
}
