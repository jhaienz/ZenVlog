import 'package:isar/isar.dart';
part 'journey.g.dart';

@collection
class Journey {
  Id id = Isar.autoIncrement;
  late DateTime startTime;
  DateTime? endTime;
  // Parallel lists because Isar 3 can't store List<LatLng> without an adapter
  List<double> trackLats = [];
  List<double> trackLngs = [];
  List<String> spotIds = [];
  String weatherSnapshot = '{}'; // raw JSON from Open-Meteo, '{}' if offline
  double totalDistanceM = 0.0;

  @ignore
  bool get isActive => endTime == null;

  @ignore
  double get durationHours => endTime == null
      ? DateTime.now().difference(startTime).inMinutes / 60
      : endTime!.difference(startTime).inMinutes / 60;
}
