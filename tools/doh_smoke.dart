// Manual smoke test: dart run tools/doh_smoke.dart
// Needs live network; overpass-api.de rate-limits (406) on repeat runs.
import 'dart:io' show exit;
// ignore_for_file: avoid_print
import 'package:app/core/net/doh_client.dart';

void main() async {
  final ip = await DohClient.resolve('overpass-api.de');
  print('resolved: $ip');
  final body = await DohClient.postViaIp(
    host: 'overpass-api.de',
    path: '/api/interpreter',
    ip: ip,
    formBody: {
      'data':
          '[out:json][timeout:10];node["natural"="peak"](13.6,123.1,13.62,123.12);out;'
    },
  );
  print(body.contains('"version"') ? 'OK' : 'FAIL: no version key');
  exit(0);
}
