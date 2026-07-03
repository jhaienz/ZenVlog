import 'package:isar/isar.dart';
import '../../core/db/isar_service.dart';
import '../persona/persona.dart';
import 'spot.dart';

class SerendipityScraper {
  static const _tagDensityThreshold = 4;

  // Weights per OSM tag: [stamina, curiosity, solitude, nature, cultural]
  static const _tagWeights = {
    'natural=water': [0.0, 0.3, 0.4, 0.9, 0.2],
    'natural=wood': [0.2, 0.5, 0.6, 0.8, 0.2],
    'natural=peak': [0.9, 0.7, 0.5, 0.6, 0.1],
    'natural=grassland': [0.3, 0.4, 0.7, 0.7, 0.1],
    'natural=cliff': [0.8, 0.8, 0.4, 0.5, 0.1],
    'natural=cave_entrance': [0.6, 0.9, 0.8, 0.6, 0.3],
  };

  /// Pure logic — used directly in tests without Isar.
  static List<Spot> filterAndRank(List<Spot> candidates, Persona persona) {
    final hidden =
        candidates.where((s) => s.tagDensity < _tagDensityThreshold).toList();
    for (final spot in hidden) {
      spot.personaScore = _score(spot, persona);
    }
    hidden.sort((a, b) => b.personaScore.compareTo(a.personaScore));
    return hidden;
  }

  static Future<List<Spot>> findHiddenSpots(Persona persona) async {
    final isar = IsarService.instance;
    final candidates = await isar.spots
        .filter()
        .tagDensityLessThan(_tagDensityThreshold)
        .findAll();
    return filterAndRank(candidates, persona);
  }

  static double _score(Spot spot, Persona persona) {
    double score = 0;
    final pv = persona.vector;
    for (final tag in spot.osmTags) {
      final weights = _tagWeights[tag];
      if (weights == null) continue;
      // Preferences (curiosity..cultural) accumulate; stamina is a constraint:
      // a demanding tag scales the whole tag score down for low-stamina users.
      double tagScore = 0;
      for (int i = 1; i < 5; i++) {
        tagScore += weights[i] * pv[i];
      }
      final staminaFit = 1 - (weights[0] - pv[0]).clamp(0.0, 1.0);
      score += tagScore * staminaFit;
    }
    return score;
  }
}
