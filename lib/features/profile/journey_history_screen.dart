import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/db/isar_service.dart';
import '../journey/journey.dart';
part 'journey_history_screen.g.dart';

@riverpod
Future<List<Journey>> completedJourneys(CompletedJourneysRef ref) =>
    IsarService.instance.journeys
        .filter()
        .endTimeIsNotNull()
        .sortByStartTimeDesc()
        .findAll();

class JourneyHistoryScreen extends ConsumerWidget {
  const JourneyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeysAsync = ref.watch(completedJourneysProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Journeys')),
      body: journeysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (journeys) {
          if (journeys.isEmpty) {
            return const Center(
                child: Text('No journeys yet — start one from Explore'));
          }
          final totalKm =
              journeys.fold(0.0, (s, j) => s + j.totalDistanceM) / 1000;
          final totalHours =
              journeys.fold(0.0, (s, j) => s + j.durationHours);
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF243D30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat('${journeys.length}', 'Journeys'),
                    _Stat('${totalKm.toStringAsFixed(0)} km', 'Distance'),
                    _Stat('${totalHours.toStringAsFixed(0)} h', 'Outdoors'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: journeys.length,
                  itemBuilder: (_, i) {
                    final j = journeys[i];
                    return ListTile(
                      title: Text('Journey ${journeys.length - i}'),
                      subtitle: Text(
                        '${j.startTime.day}/${j.startTime.month}/${j.startTime.year} · '
                        '${(j.totalDistanceM / 1000).toStringAsFixed(1)} km · '
                        '${j.durationHours.toStringAsFixed(1)} h',
                      ),
                      trailing: Text('${j.spotIds.length} spots',
                          style:
                              const TextStyle(color: Color(0xFFD4A853))),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFD4A853),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFF5F0E8), fontSize: 12)),
        ],
      );
}
