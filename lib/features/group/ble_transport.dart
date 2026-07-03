import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE transport for group discovery.
///
/// Scanning (finding nearby hosts) uses flutter_blue_plus and is real.
///
/// ponytail: advertising + GATT server hosting are stubbed —
/// flutter_blue_plus is central-only (no peripheral mode). Wire the
/// `bluetooth_low_energy` package's PeripheralManager here when two test
/// devices are available to verify the join flow. Until then a host
/// "advertises" locally only and members can't discover it over the air.
class BleTransport {
  static final Guid serviceUuid =
      Guid('12345678-1234-1234-1234-123456789012');

  static bool _advertising = false;
  static bool get isAdvertising => _advertising;

  static Future<void> startAdvertising(String hostId) async {
    _advertising = true; // stub — see class note
  }

  static Future<void> stopAdvertising() async {
    _advertising = false;
  }

  /// Scans for nearby ZenVlog group hosts. Emits device name + id.
  static Stream<({String hostId, String deviceId})> scanForGroups() async* {
    if (await FlutterBluePlus.adapterState.first !=
        BluetoothAdapterState.on) {
      return;
    }
    await FlutterBluePlus.startScan(
      withServices: [serviceUuid],
      timeout: const Duration(seconds: 10),
    );
    await for (final results in FlutterBluePlus.scanResults) {
      for (final r in results) {
        final name = r.advertisementData.advName;
        if (name.startsWith('ZenGroup:')) {
          yield (
            hostId: name.substring('ZenGroup:'.length),
            deviceId: r.device.remoteId.str,
          );
        }
      }
    }
  }

  static Future<void> stopScan() => FlutterBluePlus.stopScan();
}
