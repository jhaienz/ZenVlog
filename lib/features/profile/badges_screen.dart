import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'badges_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(badgesStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Badges')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (state) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Level ${state.level}',
                        style: const TextStyle(
                            color: Color(0xFFD4A853),
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    Text('${state.xp} XP'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 1 - (state.xpToNextLevel / 500),
                      backgroundColor: const Color(0xFF243D30),
                      color: const Color(0xFFD4A853),
                    ),
                    const SizedBox(height: 4),
                    Text('${state.xpToNextLevel} XP to next level',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final badge = state.allDefinitions[i];
                    return _BadgeTile(
                        badge: badge,
                        earned: state.earnedIds.contains(badge.id));
                  },
                  childCount: state.allDefinitions.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeDefinition badge;
  final bool earned;
  const _BadgeTile({required this.badge, required this.earned});

  static const _icons = {
    'footprint': Icons.directions_walk,
    'mic': Icons.mic,
    'route': Icons.route,
    'wb_sunny': Icons.wb_sunny,
    'brush': Icons.brush,
    'star': Icons.star,
  };

  @override
  Widget build(BuildContext context) => Tooltip(
        message: badge.description,
        child: Container(
          decoration: BoxDecoration(
            color: earned ? const Color(0xFF243D30) : const Color(0xFF1A3A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    earned ? const Color(0xFFD4A853) : Colors.transparent),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icons[badge.icon] ?? Icons.eco,
                  color: earned ? const Color(0xFFD4A853) : Colors.grey,
                  size: 32),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(badge.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: earned
                            ? const Color(0xFFD4A853)
                            : Colors.grey,
                        fontSize: 11)),
              ),
            ],
          ),
        ),
      );
}
