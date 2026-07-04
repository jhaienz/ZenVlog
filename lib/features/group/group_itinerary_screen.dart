import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../explore/serendipity_scraper.dart';
import '../explore/spot.dart';
import '../persona/persona_provider.dart';
import 'group_provider.dart';

class GroupItineraryScreen extends ConsumerStatefulWidget {
  const GroupItineraryScreen({super.key});
  @override
  ConsumerState<GroupItineraryScreen> createState() =>
      _GroupItineraryScreenState();
}

class _GroupItineraryScreenState extends ConsumerState<GroupItineraryScreen> {
  List<Spot> _spots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final group = ref.read(groupNotifierProvider);
    final myPersona = await ref.read(personaNotifierProvider.future);
    final effective = group?.mergedPersona ?? myPersona;
    if (effective == null) return;

    final spots = await SerendipityScraper.findHiddenSpots(effective);
    if (mounted) {
      setState(() {
        _spots = spots.take(5).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Itinerary')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF243D30),
                  child: const Row(
                    children: [
                      Icon(Icons.bluetooth,
                          color: Color(0xFFD4A853), size: 16),
                      SizedBox(width: 8),
                      Text('Offline Mode · Preferences merged',
                          style: TextStyle(color: Color(0xFFF5F0E8))),
                    ],
                  ),
                ),
                Expanded(
                  child: _spots.isEmpty
                      ? const Center(
                          child: Text('No spots yet — visit Explore first'))
                      : ListView.builder(
                          itemCount: _spots.length,
                          itemBuilder: (_, i) {
                            final spot = _spots[i];
                            final hour = 7 + i * 2;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF243D30),
                                child: Text(
                                    '${hour.toString().padLeft(2, '0')}:00',
                                    style: const TextStyle(
                                        color: Color(0xFFD4A853),
                                        fontSize: 11)),
                              ),
                              title: Text(spot.name),
                              subtitle:
                                  Text(spot.osmTags.take(2).join(' · ')),
                              trailing: Text(
                                  spot.personaScore.toStringAsFixed(1),
                                  style: const TextStyle(
                                      color: Color(0xFFD4A853))),
                            );
                          },
                        ),
                ),
                if (_spots.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push(kJourneyActiveRoute,
                            extra: _spots.first),
                        child: const Text('Start Journey'),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
