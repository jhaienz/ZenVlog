import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/group/group.dart';
import 'package:app/features/persona/persona.dart';

MemberPersona _member(String id, List<double> v) => MemberPersona(
      userId: id,
      displayName: id,
      persona: Persona.fromSliders(
        stamina: v[0],
        curiosity: v[1],
        solitudeNeed: v[2],
        natureAffinity: v[3],
        culturalAffinity: v[4],
      ),
    );

void main() {
  test('merge: min for Stamina/SolitudeNeed/CulturalAffinity, avg for rest', () {
    final merged = Group.computeMergedPersona([
      _member('a', [0.9, 0.6, 0.8, 0.7, 0.5]),
      _member('b', [0.3, 0.8, 0.4, 0.5, 0.9]),
    ]);
    expect(merged.stamina, 0.3); // min
    expect(merged.solitudeNeed, 0.4); // min
    expect(merged.culturalAffinity, 0.5); // min
    expect(merged.curiosity, closeTo(0.7, 0.001)); // avg
    expect(merged.natureAffinity, closeTo(0.6, 0.001)); // avg
  });

  test('single member merge equals own persona', () {
    final m = _member('a', [0.7, 0.5, 0.6, 0.8, 0.3]);
    expect(Group.computeMergedPersona([m]).vector, m.persona.vector);
  });

  test('harmonyScore 1.0 for identical personas', () {
    final g = Group(
      hostId: 'a',
      members: [
        _member('a', [0.5, 0.5, 0.5, 0.5, 0.5]),
        _member('b', [0.5, 0.5, 0.5, 0.5, 0.5]),
      ],
      mergedPersona: Persona(),
      status: GroupStatus.forming,
    );
    expect(g.harmonyScore, closeTo(1.0, 0.001));
  });

  test('harmonyScore drops for divergent personas', () {
    final g = Group(
      hostId: 'a',
      members: [
        _member('a', [1, 1, 1, 1, 1]),
        _member('b', [0, 0, 0, 0, 0]),
      ],
      mergedPersona: Persona(),
      status: GroupStatus.forming,
    );
    expect(g.harmonyScore, lessThan(0.5));
  });

  test('copyWith recomputes merged persona when members change', () {
    final g = Group(
      hostId: 'a',
      members: [_member('a', [0.9, 0.5, 0.5, 0.5, 0.5])],
      mergedPersona: Group.computeMergedPersona(
          [_member('a', [0.9, 0.5, 0.5, 0.5, 0.5])]),
      status: GroupStatus.forming,
    );
    final g2 = g.copyWith(members: [
      ...g.members,
      _member('b', [0.2, 0.5, 0.5, 0.5, 0.5]),
    ]);
    expect(g2.mergedPersona.stamina, 0.2);
  });
}
