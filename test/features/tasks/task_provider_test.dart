import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/tasks/task_provider.dart';
import 'package:app/features/tasks/task_template.dart';
import 'package:app/features/explore/spot.dart';
import 'package:app/features/persona/persona.dart';

void main() {
  test('filterTemplates excludes templates with unmatched required tags', () {
    final templates = [
      const TaskTemplate(
        id: 'water_task', title: '', description: '', type: 'sound',
        durationSeconds: 60, requiredOsmTags: ['natural=water'],
        personaAffinities: [0.5, 0.5, 0.5, 0.9, 0.5],
      ),
      const TaskTemplate(
        id: 'any_task', title: '', description: '', type: 'reflective',
        durationSeconds: 60, requiredOsmTags: [],
        personaAffinities: [0.5, 0.5, 0.5, 0.5, 0.5],
      ),
    ];
    final spot = Spot()
      ..osmId = 'x'
      ..lat = 0
      ..lng = 0
      ..osmTags = ['natural=wood'];
    final persona = Persona.fromSliders(
      stamina: 0.5, curiosity: 0.5, solitudeNeed: 0.5,
      natureAffinity: 0.5, culturalAffinity: 0.5,
    );
    final result = TaskWeaver.filterTemplates(templates, spot, persona);
    expect(result.length, 1);
    expect(result.first.id, 'any_task');
  });

  test('filterTemplates ranks by persona affinity dot product', () {
    final templates = [
      const TaskTemplate(
        id: 'low', title: '', description: '', type: 'reflective',
        durationSeconds: 60, requiredOsmTags: [],
        personaAffinities: [0.0, 0.0, 0.0, 0.0, 0.0],
      ),
      const TaskTemplate(
        id: 'high', title: '', description: '', type: 'sound',
        durationSeconds: 60, requiredOsmTags: [],
        personaAffinities: [1.0, 1.0, 1.0, 1.0, 1.0],
      ),
    ];
    final spot = Spot()
      ..osmId = 'x'
      ..lat = 0
      ..lng = 0
      ..osmTags = [];
    final persona = Persona.fromSliders(
      stamina: 0.8, curiosity: 0.8, solitudeNeed: 0.8,
      natureAffinity: 0.8, culturalAffinity: 0.8,
    );
    final result = TaskWeaver.filterTemplates(templates, spot, persona);
    expect(result.first.id, 'high');
  });

  test('filterTemplates returns at most 3 suggestions', () {
    final templates = List.generate(
      6,
      (i) => TaskTemplate(
        id: 't$i', title: '', description: '', type: 'reflective',
        durationSeconds: 60, requiredOsmTags: const [],
        personaAffinities: const [0.5, 0.5, 0.5, 0.5, 0.5],
      ),
    );
    final spot = Spot()
      ..osmId = 'x'
      ..lat = 0
      ..lng = 0
      ..osmTags = [];
    final persona = Persona.fromSliders(
      stamina: 0.5, curiosity: 0.5, solitudeNeed: 0.5,
      natureAffinity: 0.5, culturalAffinity: 0.5,
    );
    expect(TaskWeaver.filterTemplates(templates, spot, persona).length, 3);
  });
}
