import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/app_env.dart';
import 'group.dart';
import 'group_provider.dart';

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupNotifierProvider);
    return group == null ? const _NoGroupView() : _GroupView(group: group);
  }
}

class _NoGroupView extends ConsumerWidget {
  const _NoGroupView();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Group Sync')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bluetooth, size: 48, color: Color(0xFFD4A853)),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Start a group and hike together — preferences merge over Bluetooth, no internet needed.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(groupNotifierProvider.notifier).startAsHost(),
                icon: const Icon(Icons.group_add),
                label: const Text('Start Group'),
              ),
            ],
          ),
        ),
      );
}

class _GroupView extends ConsumerWidget {
  final Group group;
  const _GroupView({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text('${group.members.length} member'
              '${group.members.length == 1 ? '' : 's'} · Bluetooth Mesh'),
          actions: [
            TextButton(
              onPressed: () =>
                  ref.read(groupNotifierProvider.notifier).dissolve(),
              child: const Text('Leave',
                  style: TextStyle(color: Color(0xFFD4A853))),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Group Harmony'),
                  Text('${(group.harmonyScore * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          color: Color(0xFFD4A853),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: group.harmonyScore,
                backgroundColor: const Color(0xFF243D30),
                color: const Color(0xFFD4A853),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: group.members.length,
                itemBuilder: (_, i) {
                  final m = group.members[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF243D30),
                      child: Text(m.displayName[0],
                          style: const TextStyle(color: Color(0xFFD4A853))),
                    ),
                    title: Text(m.displayName),
                    subtitle: Text(
                      'Stamina ${(m.persona.stamina * 100).toInt()}% · '
                      'Solitude ${(m.persona.solitudeNeed * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            if (isDev)
              TextButton.icon(
                onPressed: () =>
                    ref.read(groupNotifierProvider.notifier).addTestMember(),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add test member (dev)'),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(groupNotifierProvider.notifier).activate();
                    context.push(kGroupItineraryRoute);
                  },
                  child: const Text('View Group Itinerary'),
                ),
              ),
            ),
          ],
        ),
      );
}
