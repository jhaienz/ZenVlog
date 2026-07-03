import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../app/router.dart';
import '../../core/maps/tile_cache_manager.dart';
import '../persona/persona_provider.dart';
import 'osm_downloader.dart';
import 'serendipity_scraper.dart';
import 'spot.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});
  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _mapController = MapController();
  List<Spot> _spots = [];
  LatLng _center = const LatLng(35.6762, 139.6503); // fallback: Tokyo
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _locate();
    await _loadSpots();
  }

  Future<void> _locate() async {
    try {
      final location = Location();
      if (!await location.serviceEnabled() &&
          !await location.requestService()) {
        return;
      }
      var permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
      }
      if (permission != PermissionStatus.granted) return;
      final data = await location.getLocation();
      if (data.latitude != null && data.longitude != null && mounted) {
        setState(() => _center = LatLng(data.latitude!, data.longitude!));
        _mapController.move(_center, 13);
      }
    } catch (_) {
      // keep fallback center
    }
  }

  Future<void> _loadSpots() async {
    final persona = await ref.read(personaNotifierProvider.future);
    if (persona == null) return;

    var spots = await SerendipityScraper.findHiddenSpots(persona);
    if (spots.isEmpty) {
      // First visit: fetch OSM natural features around the current center.
      try {
        await OsmDownloader.downloadRegion(
          _center.latitude - 0.1,
          _center.longitude - 0.1,
          _center.latitude + 0.1,
          _center.longitude + 0.1,
        );
        spots = await SerendipityScraper.findHiddenSpots(persona);
      } catch (e) {
        if (mounted) setState(() => _error = 'Could not load spots: offline?');
      }
    }
    if (mounted) {
      setState(() {
        _spots = spots.take(20).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 13),
            children: [
              osmTileLayer(),
              MarkerLayer(
                markers: _spots
                    .map((s) => Marker(
                          point: LatLng(s.lat, s.lng),
                          child: const Icon(Icons.eco,
                              color: Color(0xFFD4A853), size: 28),
                        ))
                    .toList(),
              ),
            ],
          ),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Finding hidden spots...',
                        style: TextStyle(color: Color(0xFF1A3A2A))),
                  ),
                ),
              ),
            ),
          if (_error != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Card(
                  color: Colors.orange[100],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!,
                        style: const TextStyle(color: Color(0xFF1A3A2A))),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomSheet: _spots.isEmpty
          ? null
          : SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _spots.length,
                itemBuilder: (_, i) => _SpotCard(
                  spot: _spots[i],
                  onTap: () => _mapController.move(
                      LatLng(_spots[i].lat, _spots[i].lng), 15),
                  onGo: () =>
                      context.push(kJourneyActiveRoute, extra: _spots[i]),
                ),
              ),
            ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  final Spot spot;
  final VoidCallback onTap;
  final VoidCallback onGo;
  const _SpotCard({required this.spot, required this.onTap, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 160,
                child: Text(spot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1A3A2A))),
              ),
              const SizedBox(height: 4),
              Text(spot.osmTags.take(2).join(' · '),
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF1A3A2A))),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Match: ${spot.personaScore.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFD4A853))),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onGo,
                    child: const Icon(Icons.arrow_circle_right,
                        color: Color(0xFF1A3A2A), size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
