import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

const _osmStore = 'osm_standard';

Future<void> initTileCache() async {
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore(_osmStore).manage.create();
}

TileLayer osmTileLayer() => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.zenvlog.app',
      tileProvider: const FMTCStore(_osmStore).getTileProvider(),
    );
