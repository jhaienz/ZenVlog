import 'package:isar/isar.dart';
part 'spot.g.dart';

@collection
class Spot {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String osmId;
  String name = 'Unnamed Place';
  late double lat;
  late double lng;
  List<String> osmTags = [];
  int tagDensity = 0;
  double personaScore = 0.0;
  DateTime discoveredAt = DateTime.now();
}
