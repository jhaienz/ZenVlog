import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../journey/journey.dart';
import '../tasks/task.dart';
part 'badges_provider.g.dart';

class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String type;
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
  factory BadgeDefinition.fromJson(Map<String, dynamic> j) => BadgeDefinition(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        icon: j['icon'] as String,
        type: j['type'] as String,
      );
}

class BadgesState {
  final int xp;
  final int level;
  final int xpToNextLevel;
  final List<String> earnedIds;
  final List<BadgeDefinition> allDefinitions;
  const BadgesState({
    required this.xp,
    required this.level,
    required this.xpToNextLevel,
    required this.earnedIds,
    required this.allDefinitions,
  });
}

class BadgesProvider {
  static int calculateXp({
    required int journeys,
    required int completedTasks,
    required double totalDistanceKm,
  }) =>
      journeys * 10 + completedTasks * 5 + (totalDistanceKm * 2).floor();

  static Set<String> earnedMilestoneBadges(int journeyCount) {
    const milestones = {
      10: 'milestone_10',
      25: 'milestone_25',
      50: 'milestone_50',
      100: 'milestone_100',
    };
    return milestones.entries
        .where((e) => journeyCount >= e.key)
        .map((e) => e.value)
        .toSet();
  }
}

@riverpod
Future<BadgesState> badgesState(BadgesStateRef ref) async {
  final isar = IsarService.instance;
  final journeys =
      await isar.journeys.filter().endTimeIsNotNull().findAll();
  final tasks =
      await isar.tasks.filter().isCompletedEqualTo(true).findAll();
  final totalDistanceKm =
      journeys.fold(0.0, (sum, j) => sum + j.totalDistanceM) / 1000;

  final xp = BadgesProvider.calculateXp(
    journeys: journeys.length,
    completedTasks: tasks.length,
    totalDistanceKm: totalDistanceKm,
  );
  final level = (xp / 500).floor() + 1;
  final xpToNext = 500 - (xp % 500);

  final earned = <String>{};
  if (journeys.isNotEmpty) earned.add('first_steps');
  earned.addAll(BadgesProvider.earnedMilestoneBadges(journeys.length));
  if (tasks.where((t) => t.templateId.startsWith('sound')).length >= 5) {
    earned.add('nature_listener');
  }
  if (tasks.where((t) => t.templateId.startsWith('sketch')).length >= 10) {
    earned.add('mindful_creator');
  }
  if (totalDistanceKm >= 50) earned.add('trail_mind');
  if (journeys.any((j) => j.startTime.hour < 7)) earned.add('early_bird');

  final data = await rootBundle.loadString('assets/badges/definitions.json');
  final defs = (jsonDecode(data) as List)
      .map((e) => BadgeDefinition.fromJson(e as Map<String, dynamic>))
      .toList();

  return BadgesState(
    xp: xp,
    level: level,
    xpToNextLevel: xpToNext,
    earnedIds: earned.toList(),
    allDefinitions: defs,
  );
}
