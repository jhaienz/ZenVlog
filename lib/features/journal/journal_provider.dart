import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import 'journal_entry.dart';
part 'journal_provider.g.dart';

@riverpod
class JournalNotifier extends _$JournalNotifier {
  @override
  Future<List<JournalEntry>> build() async {
    return IsarService.instance.journalEntrys
        .where()
        .anyId()
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<JournalEntry> add({
    required String type,
    required String content,
    int? journeyId,
    double? lat,
    double? lng,
    String? spotName,
  }) async {
    final entry = JournalEntry()
      ..type = type
      ..content = content
      ..journeyId = journeyId
      ..lat = lat
      ..lng = lng
      ..spotName = spotName;
    final isar = IsarService.instance;
    await isar.writeTxn(() => isar.journalEntrys.put(entry));
    ref.invalidateSelf();
    return entry;
  }
}
