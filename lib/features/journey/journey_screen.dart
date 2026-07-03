import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../app/router.dart';
import '../../core/maps/tile_cache_manager.dart';
import '../anshin/anshin_alert.dart';
import '../anshin/anshin_engine.dart';
import '../anshin/hazard_overlay.dart';
import '../explore/spot.dart';
import '../persona/persona_provider.dart';
import 'journey.dart';
import 'journey_provider.dart';

class JourneyScreen extends ConsumerWidget {
  final Spot destinationSpot;
  const JourneyScreen({super.key, required this.destinationSpot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyNotifierProvider);
    final journey = journeyAsync.value;
    final spot = destinationSpot;

    final trackPoints = journey == null
        ? <LatLng>[]
        : List.generate(journey.trackLats.length,
            (i) => LatLng(journey.trackLats[i], journey.trackLngs[i]));

    return Scaffold(
      appBar: AppBar(
        title: Text(spot.name),
        backgroundColor: const Color(0xFF1A3A2A),
        actions: [
          if (journey != null)
            TextButton(
              onPressed: () async {
                final ended =
                    await ref.read(journeyNotifierProvider.notifier).end();
                await ref
                    .read(personaNotifierProvider.notifier)
                    .recordCompletedJourney(ended);
                if (context.mounted) context.go(kJournalRoute);
              },
              child: const Text('End',
                  style: TextStyle(color: Color(0xFFD4A853))),
            ),
        ],
      ),
      body: Column(
        children: [
          _AnshinBanner(lat: spot.lat, lng: spot.lng),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(spot.lat, spot.lng),
                initialZoom: 15,
              ),
              children: [
                osmTileLayer(),
                FutureBuilder(
                  future: HazardOverlay.buildLayer(),
                  builder: (_, snap) =>
                      snap.data ?? const SizedBox.shrink(),
                ),
                if (trackPoints.length >= 2)
                  PolylineLayer(polylines: [
                    Polyline(
                        points: trackPoints,
                        color: const Color(0xFFD4A853),
                        strokeWidth: 4),
                  ]),
                MarkerLayer(markers: [
                  Marker(
                    point: LatLng(spot.lat, spot.lng),
                    child: const Icon(Icons.eco,
                        color: Color(0xFFD4A853), size: 32),
                  ),
                ]),
              ],
            ),
          ),
          if (journey != null) _JourneyStats(journey: journey),
        ],
      ),
      floatingActionButton: journey == null
          ? FloatingActionButton.extended(
              onPressed: () => ref
                  .read(journeyNotifierProvider.notifier)
                  .start(spot.lat, spot.lng, spotId: spot.osmId),
              label: const Text('Start Journey'),
              icon: const Icon(Icons.play_arrow),
            )
          : FloatingActionButton.extended(
              onPressed: () => context.push(kTaskRoute, extra: spot),
              label: const Text('Get Task'),
              icon: const Icon(Icons.assignment),
            ),
    );
  }
}

class _AnshinBanner extends ConsumerWidget {
  final double lat, lng;
  const _AnshinBanner({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(anshinAlertsProvider(lat, lng)).value ?? [];
    if (alerts.isEmpty) return const SizedBox.shrink();
    final worst = alerts
        .reduce((a, b) => a.severity.index > b.severity.index ? a : b);
    return Container(
      width: double.infinity,
      color: worst.severity == AlertSeverity.danger
          ? Colors.red[900]
          : Colors.orange[900],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(worst.message,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _JourneyStats extends StatelessWidget {
  final Journey journey;
  const _JourneyStats({required this.journey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A3A2A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat('${(journey.totalDistanceM / 1000).toStringAsFixed(1)} km',
              'Distance'),
          _Stat('${journey.durationHours.toStringAsFixed(1)} h', 'Time'),
          _Stat('${journey.trackLats.length}', 'Points'),
        ],
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          Text(label,
              style:
                  const TextStyle(color: Color(0xFFF5F0E8), fontSize: 12)),
        ],
      );
}
