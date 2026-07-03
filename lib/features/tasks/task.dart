import 'package:isar/isar.dart';
part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  late String templateId;
  late int journeyId;
  late String spotId;
  bool isCompleted = false;
  DateTime? completedAt;
  String? captureFilePath; // audio/photo file path
}
