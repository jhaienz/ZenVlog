import 'package:isar/isar.dart';
part 'persona.g.dart';

@collection
class Persona {
  Id id = Isar.autoIncrement;
  double stamina = 0.5;
  double curiosity = 0.5;
  double solitudeNeed = 0.5;
  double natureAffinity = 0.5;
  double culturalAffinity = 0.5;
  DateTime updatedAt = DateTime.now();
  int completedJourneys = 0;

  Persona();

  factory Persona.fromSliders({
    required double stamina,
    required double curiosity,
    required double solitudeNeed,
    required double natureAffinity,
    required double culturalAffinity,
  }) =>
      Persona()
        ..stamina = stamina
        ..curiosity = curiosity
        ..solitudeNeed = solitudeNeed
        ..natureAffinity = natureAffinity
        ..culturalAffinity = culturalAffinity
        ..updatedAt = DateTime.now();

  @ignore
  List<double> get vector =>
      [stamina, curiosity, solitudeNeed, natureAffinity, culturalAffinity];
}
