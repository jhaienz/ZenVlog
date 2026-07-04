import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import 'badges_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: badgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (state) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                      radius: 40, child: Icon(Icons.person, size: 40)),
                  const SizedBox(height: 8),
                  Text('Level ${state.level} · ${state.xp} XP',
                      style: const TextStyle(
                          color: Color(0xFFD4A853),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.emoji_events, color: Color(0xFFD4A853)),
              title: const Text('Badges & Achievements'),
              trailing:
                  Text('${state.earnedIds.length}/${state.allDefinitions.length}'),
              onTap: () => context.push('$kProfileRoute/badges'),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFFD4A853)),
              title: const Text('Journey History'),
              onTap: () => context.push('$kProfileRoute/history'),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFFD4A853)),
              title: const Text('Settings'),
              onTap: () => context.push(kSettingsRoute),
            ),
          ],
        ),
      ),
    );
  }
}
