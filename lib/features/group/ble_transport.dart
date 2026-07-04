import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart' as ble;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'group.dart';

/// BLE transport for group discovery and join.
///
/// Host side (peripheral): bluetooth_low_energy's PeripheralManager
/// advertises `ZenGroup:<hostId>` with the group service, serves the group
/// state JSON on the state characteristic, and receives join requests as
/// writes to it.
///
/// Member side (central): flutter_blue_plus scans, connects, reads the
/// state characteristic, writes a join request.
///
/// ponytail: members get a state snapshot at join — no notify push yet;
/// wire GATTCharacteristicProperty.notify + notifyCharacteristic when
/// live member-list sync matters. Over-the-air join needs two devices to
/// verify.
class BleTransport {
  static const _serviceUuidStr = '12345678-1234-1234-1234-123456789012';
  static const _stateCharUuidStr = '12345678-1234-1234-1234-123456789013';

  static final Guid serviceUuid = Guid(_serviceUuidStr);
  static final Guid stateCharUuid = Guid(_stateCharUuidStr);

  static ble.PeripheralManager? _peripheral;
  static final List<StreamSubscription> _subs = [];
  static bool get isAdvertising => _peripheral != null;

  /// Starts advertising as group host. [groupStateJson] is polled per read
  /// request so the served state always reflects the current group.
  /// [onJoinRequest] fires when a member writes a join request.
  static Future<void> startAdvertising(
    String hostId, {
    required String Function() groupStateJson,
    required void Function(MemberPersona) onJoinRequest,
  }) async {
    final manager = ble.PeripheralManager();
    if (manager.state != ble.BluetoothLowEnergyState.poweredOn) {
      throw StateError('Bluetooth is off');
    }

    await manager.removeAllServices();
    final stateChar = ble.GATTCharacteristic.mutable(
      uuid: ble.UUID.fromString(_stateCharUuidStr),
      properties: [
        ble.GATTCharacteristicProperty.read,
        ble.GATTCharacteristicProperty.write,
      ],
      permissions: [
        ble.GATTCharacteristicPermission.read,
        ble.GATTCharacteristicPermission.write,
      ],
      descriptors: [],
    );
    await manager.addService(ble.GATTService(
      uuid: ble.UUID.fromString(_serviceUuidStr),
      isPrimary: true,
      includedServices: [],
      characteristics: [stateChar],
    ));

    _subs.add(manager.characteristicReadRequested.listen((args) async {
      final value =
          Uint8List.fromList(utf8.encode(groupStateJson()));
      await manager.respondReadRequestWithValue(
        args.request,
        value: value.sublist(args.request.offset),
      );
    }));
    _subs.add(manager.characteristicWriteRequested.listen((args) async {
      try {
        onJoinRequest(MemberPersona.decode(utf8.decode(args.request.value)));
        await manager.respondWriteRequest(args.request);
      } catch (_) {
        await manager.respondWriteRequestWithError(
          args.request,
          error: ble.GATTError.unlikelyError,
        );
      }
    }));

    await manager.startAdvertising(ble.Advertisement(
      name: 'ZenGroup:$hostId',
      serviceUUIDs: [ble.UUID.fromString(_serviceUuidStr)],
    ));
    _peripheral = manager;
  }

  static Future<void> stopAdvertising() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    final manager = _peripheral;
    _peripheral = null;
    if (manager != null) {
      try {
        await manager.stopAdvertising();
        await manager.removeAllServices();
      } catch (_) {} // adapter may already be off
    }
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

  /// Member side: connect to a host, read the group state, write our join
  /// request. Returns the host's group state at time of join.
  static Future<Group> joinGroup(
      String deviceId, MemberPersona me) async {
    final device = BluetoothDevice.fromId(deviceId);
    await device.connect(timeout: const Duration(seconds: 15));
    try {
      final services = await device.discoverServices();
      final service = services.firstWhere(
          (s) => s.serviceUuid == serviceUuid,
          orElse: () => throw StateError('Group service not found'));
      final stateChar = service.characteristics.firstWhere(
          (c) => c.characteristicUuid == stateCharUuid,
          orElse: () => throw StateError('State characteristic not found'));

      final raw = await stateChar.read();
      final group = Group.decodeState(utf8.decode(raw));
      await stateChar.write(utf8.encode(me.encode()));
      return group;
    } finally {
      await device.disconnect();
    }
  }
}
