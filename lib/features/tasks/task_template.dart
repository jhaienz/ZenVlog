import 'dart:convert';
import 'package:flutter/services.dart';

class TaskTemplate {
  final String id;
  final String title;
  final String description;
  final String type; // 'sound' | 'sketch' | 'tactile' | 'reflective'
  final int durationSeconds;
  final List<String> requiredOsmTags;
  final List<double> personaAffinities; // [stamina, curiosity, solitude, nature, cultural]

  const TaskTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationSeconds,
    required this.requiredOsmTags,
    required this.personaAffinities,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> j) => TaskTemplate(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        type: j['type'] as String,
        durationSeconds: j['durationSeconds'] as int,
        requiredOsmTags: List<String>.from(j['requiredOsmTags'] as List),
        personaAffinities: List<double>.from(
            (j['personaAffinities'] as List).map((e) => (e as num).toDouble())),
      );

  static Future<List<TaskTemplate>> loadAll() async {
    final data = await rootBundle.loadString('assets/tasks/library.json');
    return (jsonDecode(data) as List)
        .map((e) => TaskTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
