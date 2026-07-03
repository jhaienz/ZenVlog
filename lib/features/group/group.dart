import 'dart:math';
import '../persona/persona.dart';

enum GroupStatus { forming, active, dissolved }

class MemberPersona {
  final String userId;
  final String displayName;
  final Persona persona;
  const MemberPersona({
    required this.userId,
    required this.displayName,
    required this.persona,
  });
}

/// A temporary 2–6 person party connected during a shared Journey.
/// In-memory only — dissolved groups leave no record.
class Group {
  final String hostId;
  final List<MemberPersona> members;
  final Persona mergedPersona;
  final GroupStatus status;

  const Group({
    required this.hostId,
    required this.members,
    required this.mergedPersona,
    required this.status,
  });

  Group copyWith({List<MemberPersona>? members, GroupStatus? status}) {
    final m = members ?? this.members;
    return Group(
      hostId: hostId,
      members: m,
      mergedPersona: computeMergedPersona(m),
      status: status ?? this.status,
    );
  }

  /// ADR-0004: constraints (Stamina, Solitude Need, Cultural Affinity)
  /// take the minimum across members; preferences (Curiosity, Nature
  /// Affinity) take the average.
  static Persona computeMergedPersona(List<MemberPersona> members) {
    if (members.isEmpty) return Persona();
    if (members.length == 1) return members.first.persona;

    double minOf(double Function(Persona) f) =>
        members.map((m) => f(m.persona)).reduce(min);
    double avgOf(double Function(Persona) f) =>
        members.map((m) => f(m.persona)).reduce((a, b) => a + b) /
        members.length;

    return Persona.fromSliders(
      stamina: minOf((p) => p.stamina),
      curiosity: avgOf((p) => p.curiosity),
      solitudeNeed: minOf((p) => p.solitudeNeed),
      natureAffinity: avgOf((p) => p.natureAffinity),
      culturalAffinity: minOf((p) => p.culturalAffinity),
    );
  }

  /// 1.0 = identical personas; falls with average pairwise squared
  /// distance across the vector.
  double get harmonyScore {
    if (members.length < 2) return 1.0;
    double totalDist = 0;
    var pairs = 0;
    for (var i = 0; i < members.length; i++) {
      for (var j = i + 1; j < members.length; j++) {
        final a = members[i].persona.vector;
        final b = members[j].persona.vector;
        double d = 0;
        for (var k = 0; k < 5; k++) {
          d += (a[k] - b[k]) * (a[k] - b[k]);
        }
        totalDist += (d / 5).clamp(0.0, 1.0);
        pairs++;
      }
    }
    return (1.0 - totalDist / pairs).clamp(0.0, 1.0);
  }
}
