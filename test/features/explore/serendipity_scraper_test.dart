import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/explore/serendipity_scraper.dart';
import 'package:app/features/explore/spot.dart';
import 'package:app/features/persona/persona.dart';

void main() {
  test('spots with tagDensity >= 4 are excluded', () {
    final spots = [
      Spot()
        ..osmId = 'a'
        ..tagDensity = 2
        ..osmTags = ['natural=water'],
      Spot()
        ..osmId = 'b'
        ..tagDensity = 5
        ..osmTags = ['natural=water', 'tourism=attraction'],
    ];
    final persona = Persona.fromSliders(
      stamina: 0.5, curiosity: 0.5, solitudeNeed: 0.5,
      natureAffinity: 0.9, culturalAffinity: 0.5,
    );
    final result = SerendipityScraper.filterAndRank(spots, persona);
    expect(result.length, 1);
    expect(result.first.osmId, 'a');
  });

  test('nature-affinity persona ranks natural=water spot higher', () {
    final spots = [
      Spot()
        ..osmId = 'peak'
        ..tagDensity = 1
        ..osmTags = ['natural=peak'],
      Spot()
        ..osmId = 'water'
        ..tagDensity = 1
        ..osmTags = ['natural=water'],
    ];
    final persona = Persona.fromSliders(
      stamina: 0.1, curiosity: 0.5, solitudeNeed: 0.5,
      natureAffinity: 0.9, culturalAffinity: 0.5,
    );
    final result = SerendipityScraper.filterAndRank(spots, persona);
    expect(result.first.osmId, 'water');
  });
}
