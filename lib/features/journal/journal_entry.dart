import 'package:isar/isar.dart';
part 'journal_entry.g.dart';

@collection
class JournalEntry {
  Id id = Isar.autoIncrement;
  int? journeyId; // nullable — entries can exist outside a journey (ADR: parent/child, child optional)
  late String type; // 'text' | 'audio' | 'photo' | 'sketch'
  late String content; // text content OR absolute file path
  double? lat;
  double? lng;
  String? spotName;
  DateTime createdAt = DateTime.now();
}
