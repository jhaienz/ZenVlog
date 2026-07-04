import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZenVlog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Design your mindful adventure',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          _HomeCard(
            icon: Icons.explore,
            title: 'Explore Hidden Spots',
            subtitle: 'Places matched to your persona',
            onTap: () => context.go(kExploreRoute),
          ),
          _HomeCard(
            icon: Icons.bluetooth,
            title: 'Group Sync',
            subtitle: 'Hike together — preferences merge offline',
            onTap: () => context.push(kGroupRoute),
          ),
          _HomeCard(
            icon: Icons.people,
            title: 'Community Feed',
            subtitle: 'Moments shared by fellow explorers',
            onTap: () => context.push(kCommunityRoute),
          ),
          _HomeCard(
            icon: Icons.book,
            title: 'My Journal',
            subtitle: 'Reflections, recordings, memories',
            onTap: () => context.go(kJournalRoute),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF1A3A2A), size: 32),
          title: Text(title,
              style: const TextStyle(
                  color: Color(0xFF1A3A2A), fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle,
              style: const TextStyle(color: Color(0xFF1A3A2A), fontSize: 12)),
          onTap: onTap,
        ),
      );
}
