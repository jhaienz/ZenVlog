import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../explore/spot.dart';
import '../persona/persona.dart';
import 'task.dart';
import 'task_template.dart';
part 'task_provider.g.dart';

/// The Contextual Task Weaver: filters the curated library by spot tags,
/// ranks by persona affinity, returns the top 3.
class TaskWeaver {
  static List<TaskTemplate> filterTemplates(
    List<TaskTemplate> all,
    Spot spot,
    Persona persona,
  ) {
    final eligible = all
        .where((t) =>
            t.requiredOsmTags.isEmpty ||
            t.requiredOsmTags.any((tag) => spot.osmTags.contains(tag)))
        .toList();

    final pv = persona.vector;
    double score(TaskTemplate t) {
      double s = 0;
      for (int i = 0; i < 5; i++) {
        s += t.personaAffinities[i] * pv[i];
      }
      return s;
    }

    eligible.sort((a, b) => score(b).compareTo(score(a)));
    return eligible.take(3).toList();
  }
}

@riverpod
Future<List<TaskTemplate>> taskSuggestions(
  TaskSuggestionsRef ref,
  Spot spot,
  Persona persona,
) async {
  final all = await TaskTemplate.loadAll();
  return TaskWeaver.filterTemplates(all, spot, persona);
}

@riverpod
class TaskNotifier extends _$TaskNotifier {
  @override
  Future<List<Task>> build(int journeyId) async {
    return IsarService.instance.tasks
        .filter()
        .journeyIdEqualTo(journeyId)
        .findAll();
  }

  Future<Task> assign(String templateId, int journeyId, String spotId) async {
    final task = Task()
      ..templateId = templateId
      ..journeyId = journeyId
      ..spotId = spotId;
    final isar = IsarService.instance;
    await isar.writeTxn(() => isar.tasks.put(task));
    ref.invalidateSelf();
    return task;
  }

  Future<void> complete(Task task, {String? captureFilePath}) async {
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    task.captureFilePath = captureFilePath;
    final isar = IsarService.instance;
    await isar.writeTxn(() => isar.tasks.put(task));
    ref.invalidateSelf();
  }
}
